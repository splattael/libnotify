
SUPPORTED_RUBIES = %w[ree 1.9.2 1.9.3 jruby rbx]
PLATFORMS = %w[ree rbx]
GEMSPEC = Bundler::GemHelper.new(Dir.pwd).gemspec

def with_ruby(ruby, command)
  rvm     = "#{ruby}@#{GEMSPEC.name}"
  command = %{rvm #{rvm} exec bash -c '#{command}'}

  puts "\n" * 3
  puts "CMD: #{command}"
  puts "=" * 40

  system command
end

namespace :rubies do
  desc "Run tests for following supported platforms #{SUPPORTED_RUBIES.join ", "}"
  task :test do
    command = "bundle check || bundle install && rake"
    SUPPORTED_RUBIES.each { |ruby| with_ruby(ruby, command) }
  end

  desc "Build gems for following supported platforms #{PLATFORMS.join ", "}"
  task :build do
    command = "rm -f Gemfile.lock && rake build"
    PLATFORMS.each { |ruby| with_ruby(ruby, command) }
  end

  desc "Pushes gems for non-ruby platforms: rbx"
  task :push => :build do
    versions = Dir[File.join("pkg", "#{GEMSPEC.name}-#{GEMSPEC.version}-*.gem")].to_a
    versions.each do |gem|
      command = "gem push #{gem}"
      puts command
      system command
    end
  end
end
