require 'helper'

class TestLibnotifyAPI < MiniTest::Unit::TestCase
  def test_without_options_and_block
    assert_equal " ",     libnotify.summary
    assert_equal " ",     libnotify.body
    assert_equal :normal, libnotify.urgency
    assert_nil            libnotify.timeout
    assert_nil            libnotify.icon_path
    assert                libnotify.append
  end

  def test_with_options_and_block
    libnotify(:summary => "hello", :body => "body", :invalid_option => 23) do |n|
      n.body      = "overwritten"
      n.icon_path = "/path/to/icon"
      n.append    = false
    end

    assert_equal "hello",         libnotify.summary
    assert_equal "overwritten",   libnotify.body
    assert_equal "/path/to/icon", libnotify.icon_path
    assert                       !libnotify.append
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

  def test_mocked_ffi_provider
    provider = mocked_ffi_provider
    assert_equal 0, provider.called.size

    provider.notify_init
    assert_equal 1, provider.called.size
    assert_equal :notify_init, provider.called.last[0]
    assert_equal [], provider.called.last[1]

    provider.notify_init "test"
    assert_equal :notify_init, provider.called.last[0]
    assert_equal ["test"], provider.called.last[1]
  end

  def test_mocked_notify
    provider = mocked_ffi_provider
    libnotify(:ffi => provider).show!

    assert_equal 9, provider.called.size
    # TODO assert_method_called
  end

  private

  def libnotify(options={}, &block)
    @libnotify ||= Libnotify::API.new(options, &block)
  end

  def mocked_ffi_provider
    Class.new do
      attr_reader :called

      def initialize
         @called = []
      end

      def method_missing(name, *args, &block)
        if name.to_s =~ /^notify_/
          @called << [ name, args ]
        else
          super
        end
      end
    end.new
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

  def assert_method_called(expected_name, *expected_args)
    found = libnotify.methods.select do |name, *args|
      expected_name == name && expected_name == args
    end
    assert_equal 1, found.size, "found #{expected_name}(#{expected_args.inspect}) excatly 1 time"
  end

end
