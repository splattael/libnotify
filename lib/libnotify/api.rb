require 'libnotify/ffi'
require 'libnotify/icon_finder'

module Libnotify
  # API for Libnotify
  #
  # @see Libnotify
  class API
    include FFI

    attr_reader :timeout, :icon_path
    attr_accessor :app_name, :summary, :body, :urgency, :append, :transient

    class << self
      # List of globs to icons
      attr_accessor :icon_dirs
    end

    self.icon_dirs = [
      "/usr/share/icons/gnome/*/emblems",
      "/usr/share/icons/gnome/*/emotes"
    ]

    # Creates a notification object.
    #
    # @see Libnotify.new
    def initialize(options={}, &block)
      set_defaults
      apply_options(options, &block)
    end

    def apply_options(options={})
      options.each { |key, value| send("#{key}=", value) if respond_to?(key) }
      yield(self) if block_given?
    end
    private :apply_options

    def set_defaults
      self.app_name = self.class.to_s
      self.summary = self.body = ' '
      self.urgency = :normal
      self.timeout = nil
      self.append = true
      self.transient = false
    end
    private :set_defaults

    # Shows a new notification.
    #
    # @see Libnotify.show
    def show!
      notify_init(app_name) or raise "notify_init failed"
      @notification = notify_notification_new(summary, body, icon_path, nil)
      show
    end

    # Shows an existing notification.
    def show
      notify_notification_set_urgency(@notification, urgency)
      notify_notification_set_timeout(@notification, timeout || -1)
      set_hints
      notify_notification_show(@notification, nil)
    ensure
      clear_hints
    end

    # Updates a previously shown notification or creates a new one.
    def update(options={}, &block)
      apply_options(options, &block)
      if @notification
        notify_notification_update(@notification, summary, body, icon_path, nil)
        show
      else
        show!
      end
    end

    # Close a previously shown notification.
    def close
      notify_notification_close(@notification, nil) if @notification
    end

    # @todo Simplify timeout=
    def timeout=(timeout)
      @timeout = case timeout
      when Float
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

    # Sets icon path.
    #
    # Path can be absolute, relative (will be resolved) or a symbol.
    #
    # @todo document and refactor
    def icon_path=(path)
      case path
      when %r{^/} # absolute
        @icon_path = path
      when String
        @icon_path = icon_for(path)
      when Symbol
        self.icon_path = "#{path}.png"
      else
        @icon_path = nil
      end
    end

    # Creates and shows a notification. It's a shortcut for +Libnotify.new(options).show!+.
    #
    # @see Libnotify.show
    # @see Libnotify.new
    def self.show(options={}, &block)
      new(options, &block).show!
    end

    private

    def set_hints
      if append
        notify_notification_set_hint_string(@notification, "x-canonical-append", "")
        notify_notification_set_hint_string(@notification, "append", "")
      end
      if transient
        notify_notification_set_hint_uint32(@notification, "transient", 1)
      end
    end

    def clear_hints
      notify_notification_clear_hints(@notification) if (append || transient)
    end

    def icon_for(name)
      IconFinder.new(self.class.icon_dirs).icon_path(name) || name
    end
  end
end
