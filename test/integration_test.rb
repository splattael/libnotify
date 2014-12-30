require 'helper'

class IntegrationTest < LibnotifyTestCase
  test "display notification" do
    libnotify = Libnotify::API.new(:timeout => 0.5, :icon_path => :"emblem-favorite", :append => true)

    [ :low, :normal, :critical ].each do |urgency|
      libnotify.app_name = "test"
      libnotify.summary = "#{RUBY_VERSION} at #{RUBY_PLATFORM}"
      libnotify.body    = [ urgency, defined?(RUBY_DESCRIPTION) ? RUBY_DESCRIPTION : '?' ].join(" ")
      libnotify.urgency = urgency
      libnotify.show!
    end
  end
end
