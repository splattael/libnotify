#!/usr/bin/env bundle exec watchr

def run(cmd)
  puts(cmd)
  system cmd
end

def run_test_file(file)
  clear
  run "ruby -rubygems -Ilib:test #{file}"
end

def run_tests
  clear
  run "rake"
end

def clear
  system "clear"
end

def underscore(file)
  file.gsub('/', '_')
end

@interrupted = false

Signal.trap 'QUIT' do
  run_tests
end

Signal.trap 'INT' do
  if @interrupted then
    abort("\n")
  else
    puts "Interrupt a second time to quit"
    @interrupted = true
    Kernel.sleep 1.5
    # raise Interrupt, nil # let the run loop catch it
    run_tests
  end
end

run_tests

watch('test/test_.*\.rb') {|md| run_test_file md[0] }
watch('lib/(.*)\.rb') {|md| run_test_file "test/test_#{underscore(md[1])}.rb" }
watch('test/helper.rb') { run_tests }
