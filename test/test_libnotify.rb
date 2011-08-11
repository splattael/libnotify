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

class TestLibnotifyAPI < MiniTest::Unit::TestCase
  def test_without_options_and_block
    assert_equal " ",     libnotify.summary
    assert_equal " ",     libnotify.body
    assert_equal :normal, libnotify.urgency
    assert_nil            libnotify.timeout
    assert_nil            libnotify.icon_path
    assert                libnotify.append
    assert               !libnotify.transient
  end

  def test_with_options_and_block
    libnotify(:summary => "hello", :body => "body", :invalid_option => 23) do |n|
      n.body      = "overwritten"
      n.icon_path = "/path/to/icon"
      n.append    = false
      n.transient = true
    end

    assert_equal "hello",         libnotify.summary
    assert_equal "overwritten",   libnotify.body
    assert_equal "/path/to/icon", libnotify.icon_path
    assert                       !libnotify.append
    assert                        libnotify.transient
  end

  def test_timeout_setter
    assert_timeout 2500,  2.5,    "with float"
    assert_timeout 100,   100,    "with fixnum ms"
    assert_timeout 101,   101,    "with fixnum ms"
    assert_timeout 1000,  1,      "with fixnum seconds"
    assert_timeout 99000, 99,     "with fixnum seconds"
    assert_timeout nil,   nil,    "with nil"
    assert_timeout nil,   false,  "with false"
    assert_timeout 2,     :"2 s", "with to_s.to_i"
  end

  def test_icon_path_setter
    Libnotify::API.icon_dirs << File.expand_path("../..", __FILE__)
    assert_icon_path "/some/path/image.jpg",  "/some/path/image.jpg",   "with absolute path"
    assert_icon_path "some-invalid-path.jpg", "some-invalid-path.jpg",  "with non-existant relative path"
    assert_icon_path %r{^/.*/libnotify.png},  "libnotify.png",          "with relative path"
    assert_icon_path %r{^/.*/libnotify.png},  :"libnotify",             "with symbol"
  end

  def test_integration
    skip "enable integration"

    libnotify = Libnotify::API.new(:timeout => 0.5, :icon_path => :"emblem-favorite", :append => true)

    [ :low, :normal, :critical ].each do |urgency|
      libnotify.summary = "#{RUBY_VERSION} at #{RUBY_PLATFORM}"
      libnotify.body    = [ urgency, defined?(RUBY_DESCRIPTION) ? RUBY_DESCRIPTION : '?' ].join(" ")
      libnotify.urgency = urgency
      libnotify.show!
    end
  end

  private

  def libnotify(options={}, &block)
    @libnotify ||= Libnotify::API.new(options, &block)
  end

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

end
