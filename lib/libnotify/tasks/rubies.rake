SUPPORTED_RUBIES = %w[ree 1.9.2 jruby rbx]

GEMSPEC = Bundler::GemHelper.new(Dir.pwd).gemspec

def with_rubies(command)
  SUPPORTED_RUBIES.each do |ruby|
    with_ruby(ruby, command)
  end
end

def with_ruby(ruby, command)
  rvm     = "#{ruby}@#{GEMSPEC.name}"
  command = %{rvm #{rvm} exec bash -c '#{command}'}

  puts "\n" * 3
  puts "CMD: #{command}"
  puts "=" * 40

  system command
end

namespace :rubies do
  desc "Run tests for following supported platforms #{SUPPORTED_RUBIES.inspect}"
  task :test do
    command = "bundle check || bundle install && rake"
    with_rubies(command)
  end

  desc "Build gems for following supported platforms #{SUPPORTED_RUBIES.inspect}"
  task :build do
    command = "rake build"
    with_rubies(command)
  end

  desc "Pushes gems for following supported platforms #{SUPPORTED_RUBIES.inspect}"
  #task :push => :build do
  task :push do
    Dir[File.join("pkg", "#{GEMSPEC.name}-#{GEMSPEC.version}*.gem")].each do |gem|
      command = "gem push #{gem}"
      puts command
      system command
    end
  end

end
