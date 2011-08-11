# Ruby bindings for libnotify using FFI.
#
# See README.rdoc for usage examples.
#
# @see README.rdoc
# @see Libnotify.new
# @author Peter Suschlik
module Libnotify
  # Creates a notification.
  #
  # @example Block syntax
  #   n = Libnotify.new do |notify|
  #     notify.summary    = "hello"
  #     notify.body       = "world"
  #     notify.timeout    = 1.5         # 1.5 (s), 1000 (ms), "2", nil, false
  #     notify.urgency    = :critical   # :low, :normal, :critical
  #     notify.append     = false       # default true - append onto existing notification
  #     notify.transient  = true        # default false - keep the notifications around after display
  #     notify.icon_path  = "/usr/share/icons/gnome/scalable/emblems/emblem-default.svg"
  #   end
  #   n.show!
  #
  # @example Hash syntax
  #   Libnotify.show(:body => "hello", :summary => "world", :timeout => 2.5)
  #
  # @example Mixed syntax
  #   Libnotify.new(options) do |n|
  #     n.timeout = 1.5     # overrides :timeout in options
  #     n.show!
  #   end
  #
  # @param [Hash] options  options creating a notification
  # @option options [String] :summary (' ') summary/title of the notification
  # @option options [String] :body (' ') the body
  # @option options [Fixnum, Float, nil, FalseClass, String] :timeout (nil) display duration of the notification.
  #   Use +false+ or +nil+ for no timeout.
  # @option options [Symbol] :urgency (:normal) the urgency of the notification.
  #   Possible values are: +:low+, +:normal+ and +:critical+
  # @option options [String] :icon_path path the an icon displayed.
  #
  # @yield [notify]   passes the notification object
  # @yieldparam [API] notify the notification object
  #
  # @return [API] the notification object
  def self.new(options={}, &block)
    API.new(options, &block)
  end

  # Shows a notification. It takes the same +options+ as Libnotify.new.
  #
  # @see Libnotify.new
  def self.show(options={}, &block)
    API.show(options, &block)
  end

  autoload  :VERSION, 'libnotify/version'
  autoload  :API,     'libnotify/api'
  autoload  :FFI,     'libnotify/ffi'
end
