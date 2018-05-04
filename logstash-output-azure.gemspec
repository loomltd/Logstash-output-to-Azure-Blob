Gem::Specification.new do |s|
  s.name          = 'logstash-output-azure'
  s.version       = '1.0.4'
  s.licenses      = ['Apache-2.0']
  s.summary       = 'Plugin for logstash to send output to Microsoft Azure Blob'
  s.description   = 'This plugin receives events, outputs them to a temporary file and uploads them to Azure Blob storage using the azure-storage libreary'
  s.homepage      = 'https://github.com/paulpc/Logstash-output-to-Azure-Blob'
  s.authors       = ['Tuffk','paulpc']
  s.email         = 'praetor44@gmail.com'
  s.require_paths = ['lib']

  # Files
  s.files = Dir['lib/**/*', 'spec/**/*', 'vendor/**/*', '*.gemspec', '*.md', 'CONTRIBUTORS', 'Gemfile', 'LICENSE', 'NOTICE.TXT']
  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { 'logstash_plugin' => 'true', 'logstash_group' => 'output' }

  # Gem dependencies
  s.add_runtime_dependency 'azure-storage', '~> 0.15.0.preview'
  s.add_runtime_dependency 'logstash-codec-plain'
  s.add_runtime_dependency 'logstash-core-plugin-api', '~> 2.1'
  s.add_development_dependency 'logstash-devutils'
end
