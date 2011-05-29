
def run_tests
  system "rake"
end

def underscore(name)
  name.split('/').join('_')
end

watch %r{lib/(.*).rb} do |f|
  run_tests
end

watch %r{test/(.*).rb} do |f|
  run_tests
end

run_tests
