require "bundler/gem_tasks"

task :default => :test

desc "Run all test cases"
task :test do
  $LOAD_PATH.unshift('lib', 'test')
  Dir.glob('./test/**/*_tc.rb').each { |file| require file}
end

