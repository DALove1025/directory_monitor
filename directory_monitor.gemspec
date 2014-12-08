# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'directory_monitor/version'

Gem::Specification.new do |spec|
  spec.name          = "directory_monitor"
  spec.version       = DirectoryMonitor::VERSION
  spec.authors       = ["David A. Love"]
  spec.email         = ["DALove1025@gmail.com"]
  spec.description   = %q{Monitor a directory for file changes.}
  spec.summary       = %q{A Directory Monitor}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'trollop', '~> 2.0'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
