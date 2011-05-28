require 'helper'

class TestLibnotify < MiniTest::Unit::TestCase
  def test_respond_to
    assert_respond_to Libnotify, :new
    assert_respond_to Libnotify, :show
  end

  def test_delegation
    skip "test delegation using mock"

    # old code
    asserts("#new calls API#new") do
      mock(Libnotify::API).new(hash_including(:body => "test")) { true }
      Libnotify.new(:body => "test")
    end
    asserts("#show calls API#show") do
      mock(Libnotify::API).show(hash_including(:body => "test")) { true }
      Libnotify.show(:body => "test")
    end
  end

  def test_version
    assert defined?(Libnotify::VERSION), "version is defined"
    assert Libnotify::VERSION
  end
end
