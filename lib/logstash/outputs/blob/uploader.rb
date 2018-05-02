require 'logstash/util'
require "azure/storage"
module LogStash
  module Outputs
    class LogstashAzureBlobOutput
      # a sub class of +LogstashAzureBlobOutput+
      # this class uploads the files to Azure cloud
      class Uploader
        TIME_BEFORE_RETRYING_SECONDS = 1
        DEFAULT_THREADPOOL = Concurrent::ThreadPoolExecutor.new(min_threads: 1,
                                                                max_threads: 8,
                                                                max_queue: 1,
                                                                fallback_policy: :caller_runs)

        attr_accessor :upload_options, :logger, :container_name, :blob_account

        # Initializes the class
        # @param blob_account [Object] endpoint to azure gem
        # @param container_name [String] name of the container in azure blob, at this point, if it doesn't exist, it was already created
        def initialize(blob_account, container_name, logger, threadpool = DEFAULT_THREADPOOL)
          @blob_account = blob_account
          @workers_pool = threadpool
          @logger = logger
          @container_name = container_name
        end

        # Create threads to upload the file to the container
        def upload_async(file, options = {})
          @workers_pool.post do
            LogStash::Util.set_thread_name("LogstashAzureBlobOutput output uploader, file: #{file.path}")
            upload(file, options)
          end
        end

        def upload(file, options = {})
          upload_options = options.fetch(:upload_options, {})

          begin
            filename = Object::File.basename file.path
            puts filename
            block_size = 33554432
            blocks = []
            Object::File.open(file.path, 'rb') do |file|
              while (file_bytes = file.read(block_size))

                block_id = Base64.strict_encode64((0...8).map { ('a'..'z').to_a[rand(26)] }.join)
                blob_account.put_blob_block(container_name, filename, block_id, file_bytes)
        
                blocks << [block_id]
              end
            end
            # comitting the containers
            blob = blob_account.commit_blob_blocks(container_name, filename, blocks)

            list_blocks = blob_account.list_blob_blocks(container_name, filename)
            list_blocks[:committed].each { |block| puts "Committed Block #{block.name}" }

          rescue Errno::ENOENT => e
            # the file has gone missing - let's not fill up the drive with errors
            logger.error('Uploading failed - giving up on the missing file', exception: e.class, message: e.message, path: file.path, backtrace: e.backtrace)

          rescue => e
            # When we get here it usually mean that LogstashAzureBlobOutput tried to do some retry by himself (default is 3)
            # When the retry limit is reached or another error happen we will wait and retry.
            #
            # Thread might be stuck here, but I think its better than losing anything
            # its either a transient errors or something bad really happened.
            logger.error('Uploading failed, retrying', exception: e.class, message: e.message, path: file.path, backtrace: e.backtrace)
            retry
          end

          options[:on_complete].call(file) unless options[:on_complete].nil?
          blob
        rescue => e
          logger.error('An error occured in the `on_complete` uploader',
                       exception: e.class,
                       message: e.message,
                       path: file.path,
                       backtrace: e.backtrace)
          raise e # reraise it since we don't deal with it now
        end

        # stop threads
        def stop
          @workers_pool.shutdown
          @workers_pool.wait_for_termination(nil) # block until its done
        end
      end
    end
  end
end
