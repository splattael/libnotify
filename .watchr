
def run(*args)
  system "ruby -rubygems -Ilib:test #{args.join(' ')}"
end

def run_tests
  system "rake test"
end

def underscore(file)
  file.gsub('/', '_')
end

watch('test/test_.*\.rb')  {|md| run md[0] }
watch('lib/(.*)\.rb')      {|md| run "test/test_#{underscore(md[1])}.rb" }
watch('test/helper.rb')    { run_tests }

run_tests

Signal.trap("QUIT") { abort("\n") }
Signal.trap("INT") { run_tests }
