require 'ffi'

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
  #     notify.summary = "world"
  #     notify.body = "hello"
  #     notify.timeout = 1.5        # 1.5 (s), 1000 (ms), "2", nil, false
  #     notify.urgency = :critical  # :low, :normal, :critical
  #     notify.icon_path = "/usr/share/icons/gnome/scalable/emblems/emblem-default.svg"
  #   end
  #   n.show!
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
  # @example Block syntax
  #   Libnotify.show do |notify|
  #     notify.summary = "world"
  #     notify.body = "hello"
  #     notify.timeout = 1.5        # 1.5 (s), 1000 (ms), "2", nil, false
  #     notify.urgency = :critical  # :low, :normal, :critical
  #     notify.icon_path = "/usr/share/icons/gnome/scalable/emblems/emblem-default.svg"
  #   end
  #
  # @example Hash syntax
  #   Libnotify.show(:body => "hello", :summary => "world", :timeout => 2.5)
  #
  # @see Libnotify.new
  def self.show(options={}, &block)
    API.show(options, &block)
  end

  # Raw FFI bindings.
  module FFI
    extend ::FFI::Library

    ffi_lib %w(libnotify libnotify.so libnotify.so.1)

    enum :urgency, [ :low, :normal, :critical ]

    attach_function :notify_init, [:string], :bool
    attach_function :notify_uninit, [], :void

    attach_function :notify_notification_new, [:string, :string, :string, :pointer], :pointer
    attach_function :notify_notification_set_urgency, [:pointer, :urgency], :void
    attach_function :notify_notification_set_timeout, [:pointer, :long], :void
    attach_function :notify_notification_show, [:pointer, :pointer], :bool
  end

  class API
    include FFI

    attr_reader :timeout
    attr_accessor :summary, :body, :icon_path, :urgency

    # Creates a notification object.
    #
    # @see Libnotify.new
    def initialize(options={}, &block)
      set_defaults
      options.each { |key, value| send("#{key}=", value) if respond_to?(key) }
      yield(self) if block_given?
    end

    def set_defaults
      self.summary = self.body = ' '
      self.urgency = :normal
      self.timeout = nil
    end
    private :set_defaults

    # Shows a notification.
    #
    # @see Libnotify.show
    def show!
      notify_init(self.class.to_s) or raise "notify_init failed"
      notify = notify_notification_new(summary, body, icon_path, nil)
      notify_notification_set_urgency(notify, urgency)
      notify_notification_set_timeout(notify, timeout || -1)
      notify_notification_show(notify, nil)
    end

    # @todo Simplify timeout=
    def timeout=(timeout)
      @timeout = case timeout
      when Float
        timeout /= 10 if RUBY_VERSION == "1.8.6" # Strange workaround?
        (timeout * 1000).to_i
      when Fixnum
        if timeout >= 100 # assume miliseconds
          timeout
        else
          timeout * 1000
        end
      when NilClass, FalseClass
        nil
      else
        timeout.to_s.to_i
      end
    end

    # Creates and shows a notification. It's a shortcut for +Libnotify.new(options).show!+.
    #
    # @see Libnotify.show
    # @see Libnotify.new
    def self.show(options={}, &block)
      new(options, &block).show!
    end

  end

end
