require 'bundler'
Bundler::GemHelper.install_tasks

RUBIES = %w[ree 1.9.2 jruby]

require 'rake'
require 'rake/rdoctask'
require 'rubygems'

# Test
require 'rake/testtask'
desc 'Default: run unit tests.'
task :default => :test

Rake::TestTask.new(:test) do |test|
  test.test_files = FileList.new('test/test_*.rb')
  test.libs << 'test'
  test.verbose = true
end

desc "Test with several ruby versions"
task :"test:rubies" do
  command = "bundle check || bundle install && rake"
  RUBIES.each do |ruby|
    rvm = "#{ruby}@libnotify"
    puts "\n" * 3
    puts "RVM: #{rvm}"
    puts "=" * 40

    system %{rvm #{rvm} exec bash -c '#{command}'}
  end
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
