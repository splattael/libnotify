require 'rubygems'
require 'bundler/setup'
require 'simplecov' if ENV['COVERAGE'] == '1'

require 'minitest/autorun'
require 'minitest/libnotify'

require 'libnotify'

module LibnotifyAssertions
  def assert_timeout(expected, value, message)
    assert_value_set :timeout, expected, value, message
  end

  def assert_icon_path(expected, value, message)
    assert_value_set :icon_path, expected, value, message
  end

  def assert_value_set(attribute, expected, value, message)
    libnotify.send("#{attribute}=", value)
    got = libnotify.send(attribute)
    case expected
    when Regexp
      assert_match expected, got, message
    else
      assert_equal expected, got, message
    end
  end

  def fixture_file(path)
    File.expand_path(File.join(File.dirname(__FILE__), "fixtures", path))
  end
end

class LibnotifyTestCase < MiniTest::Spec
  include LibnotifyAssertions

  class << self
    alias :test :it
    alias :context :describe
    alias :setup :before
    alias :teardown :after
  end

  def libnotify(options={}, &block)
    @libnotify ||= Libnotify::API.new(options, &block)
  end
end
