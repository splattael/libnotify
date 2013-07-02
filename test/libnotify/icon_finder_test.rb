require 'helper'

require 'fileutils'

class LibnotifyIconFinderTest < LibnotifyTestCase
  test "find icon with highest resolution" do
    dir = fixture_file("/icons/*")
    assert_icon_path [ dir ], "/icons/128x128/happy.jpg", "happy.jpg"
  end

  test "search all provided dirs" do
    dirs = [ fixture_file("/icons/*"), fixture_file("/emoticons/*") ]

    assert_icon_path dirs, "/emoticons/128x128/happy.jpg", "happy.jpg"
  end

  test "does not find unknown icons" do
    dir = fixture_file("/icons/*")
    refute icon_finder([ dir ]).icon_path("unknown.jpg")
  end

  test "does not find known icon in unknown dirs" do
    dir = fixture_file("/unknown/*")
    refute icon_finder([ dir ]).icon_path("happy.jpg")
  end

  test "find icon alphabetically w/o resolution" do
    dir = fixture_file("/images/*")
    assert_icon_path [ dir ], "/images/another/happy.jpg", "happy.jpg"
  end

  private

  def icon_finder(*dirs)
    Libnotify::IconFinder.new(dirs)
  end

  def assert_icon_path(dirs, expected, name)
    assert_equal fixture_file(expected), icon_finder(*dirs).icon_path(name)
  end
end
