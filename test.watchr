#!/usr/bin/env watchr
 
begin
  require File.join(ENV["HOME"], ".watchr.test.rb")
rescue LoadError
  warn "Unable to load #{File.join(ENV["HOME"], ".watchr.test.rb")}"
  warn "You might try this: http://gist.github.com/raw/273574/8804dff44b104e9b8706826dc8882ed985b4fd13/.watchr.test.rb"
  exit
end
 
run_tests
 
watch('test/test_.*\.rb') {|md| run md[0] }
watch('lib/(.*)\.rb') {|md| run "test/test_#{underscore(md[1])}.rb" }
watch('test/helper.rb') { run_tests }
