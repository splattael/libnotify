SUPPORTED_RUBIES = %w[ree 1.9.3 2.0.0 jruby rbx]
GEMSPEC = Bundler::GemHelper.new(Dir.pwd).gemspec

def with_ruby(ruby, command)
  gemset  = GEMSPEC.name
  command = %{rvm #{ruby}@#{gemset} --create do bash -c '#{command}'}

  puts "\n" * 3
  puts "CMD: #{command}"
  puts "=" * 40

  system command
end

namespace :rubies do
  desc "Run tests for following supported platforms #{SUPPORTED_RUBIES.join ", "}"
  task :test do
    command = "rm -f Gemfile.lock && bundle install && bundle exec rake"
    SUPPORTED_RUBIES.each { |ruby| with_ruby(ruby, command) }
  end
end
