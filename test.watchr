
def run_tests
  system "clear && rake"
end

def underscore(name)
  name.split('/').join('_')
end

watch %r{.*.rb} do |f|
  run_tests
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
