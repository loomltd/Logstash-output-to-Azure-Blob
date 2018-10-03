# Logstash Plugin
[![Build Status](https://travis-ci.org/paulpc/Logstash-output-to-Azure-Blob.svg?branch=master)](https://travis-ci.org/paulpc/Logstash-output-to-Azure-Blob)

This is a plugin for [Logstash](https://github.com/elastic/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

This plugin has been forked and modified from [tuffk/Logstash-output-to-Azure-Blob](https://github.com/tuffk/Logstash-output-to-Azure-Blob) through [loomltd/Logstash-output-to-Azure-Blob](https://github.com/loomltd/logstash-output-to-azure-blob)
## Documentation

### How to install the plugin
- create the gem file
```sh
gem build logstash-output-azure.gemspec
```
- Install plugin
```sh
sudo /usr/share/logstash/bin/logstash-plugin install --no-verify /path/to/gem/file/logstash-output-azure-[version].gem
```
- Restart Logstash and proceed to test the plugin
```sh
sudo systemctl restart logstash
```
### How to use the plugin:
Use this output in the pipelines where you need to output to blob.
```
output {
     azure {
        storage_account_name => "my-azure-account"    # required
        storage_access_key => "my-super-secret-key"   # required
        container_name => "my-container"              # required
        prefix => "a_prefix"                          # required - unique across pipelines
        storage_path => "path/on/the/blob/store"      # optional
        size_file => 1024*1024*5                      # optional - size in bytes - keep in mind the size of the temp folder
        time_file => 10                               # optional
        restore => true                               # optional
        temporary_directory => "path/to/directory"    # optional
        upload_queue_size => 2                        # optional
        upload_workers_count => 1                     # optional
        rotation_strategy_val => "size_and_time"      # optional
        tags => []                                    # optional - will be used in the begining of the file name
        encoding => "none"                            # optional (none or gzip) - the none will output as json lines
        codec => "json_lines"                         # optional - the codec of the files - e.g. json_lines or unformattet plain log lines
      }
    }
```
