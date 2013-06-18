require 'bundler/setup'
Bundler::GemHelper.install_tasks

require 'rake'
require 'rubygems'
load 'libnotify/tasks/rubies.rake'

# Test
require 'rake/testtask'
desc 'Default: run unit tests.'
task :default => :test

Rake::TestTask.new(:test) do |test|
  test.test_files = FileList.new('test/**/*_test.rb')
  test.libs << 'test'
  test.verbose = true
end
# Yard
begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end

desc "Alias for `rake yard`"
task :doc => :yard

# Misc
desc "Tag files for vim"
task :ctags do
  dirs = $LOAD_PATH.select {|path| File.directory?(path) }
  system "ctags -R #{dirs.join(" ")}"
end

desc "Find whitespace at line ends"
task :eol do
  system "grep -nrE ' +$' *"
end

desc "Display TODOs"
task :todo do
  `grep -Inr TODO lib test`.each do |line|
    line.scan(/^(.*?:.*?):\s*#\s*TODO\s*(.*)$/) do |(file, todo)|
      puts "* #{todo} (#{file})"
    end
  end
end
