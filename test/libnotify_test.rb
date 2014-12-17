require 'helper'

class LibnotifyTest < LibnotifyTestCase
  test "responds to new" do
    assert_respond_to Libnotify, :new
  end

  test "responds to show" do
    assert_respond_to Libnotify, :show
  end

  test "has version" do
    assert defined?(Libnotify::VERSION), "version is defined"
    assert Libnotify::VERSION
  end

  test "delegates icons_dir" do
    assert_equal Libnotify::API.icon_dirs, Libnotify.icon_dirs
  end
end
