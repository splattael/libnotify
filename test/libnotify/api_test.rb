require 'helper'

class LibnotifyAPITest < LibnotifyTestCase
  test "instance default values" do
    assert_equal "Libnotify::API",  libnotify.app_name
    assert_equal " ",               libnotify.summary
    assert_equal " ",               libnotify.body
    assert_equal :normal,           libnotify.urgency
    assert_nil                      libnotify.timeout
    assert_nil                      libnotify.icon_path
    assert                          libnotify.append
    refute                          libnotify.transient
  end

  test "instance with options and block" do
    libnotify(:summary => "hello", :body => "body", :invalid_option => 23) do |n|
      n.app_name  = "foo"
      n.body      = "overwritten"
      n.icon_path = "/path/to/icon"
      n.append    = false
      n.transient = true
    end

    assert_equal "foo",           libnotify.app_name
    assert_equal "hello",         libnotify.summary
    assert_equal "overwritten",   libnotify.body
    assert_equal "/path/to/icon", libnotify.icon_path
    refute                        libnotify.append
    assert                        libnotify.transient
  end

  test "timeout=" do
    assert_timeout 2500,  2.5,    "with float"
    assert_timeout 100,   100,    "with fixnum ms"
    assert_timeout 101,   101,    "with fixnum ms"
    assert_timeout 1000,  1,      "with fixnum seconds"
    assert_timeout 99000, 99,     "with fixnum seconds"
    assert_timeout nil,   nil,    "with nil"
    assert_timeout nil,   false,  "with false"
    assert_timeout 2,     :"2 s", "with to_s.to_i"
  end

  test "icon_path=" do
    Libnotify::API.icon_dirs << File.expand_path("../../fixtures", __FILE__)
    assert_icon_path "/some/path/image.jpg",  "/some/path/image.jpg",   "with absolute path"
    assert_icon_path "some-invalid-path.jpg", "some-invalid-path.jpg",  "with non-existant relative path"
    assert_icon_path %r{^/.*/test/fixtures/libnotify.png}, "libnotify.png", "with relative path"
    assert_icon_path %r{^/.*/test/fixtures/libnotify.png}, :"libnotify",    "with symbol"
  end

  test "update" do
    libnotify(:summary => "hello", :body => "world").show!
    libnotify.update(:summary => "hell") do |n|
      n.body = "yeah"
    end
    assert_equal "hell", libnotify.summary
    assert_equal "yeah", libnotify.body
    libnotify.close
  end

  test "raise ArgumentError for unknown urgency" do
    e = assert_raises ArgumentError do
      libnotify(:urgency => :unknown).show!
    end
    assert_equal "invalid enum value, :unknown", e.message
  end
end
