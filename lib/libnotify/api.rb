module Libnotify
  # API for Libnotify
  #
  # @see Libnotify
  class API
    include FFI

    attr_reader :timeout, :icon_path
    attr_accessor :summary, :body, :urgency, :append, :transient

    class << self
      # List of globs to icons
      attr_accessor :icon_dirs
    end

    self.icon_dirs = [
      "/usr/share/icons/gnome/*/emblems",
      "/usr/share/icons/gnome/*/emotes"
    ]

    # TODO refactor & test!
    ICON_REGEX = /(\d+)x\d/
    ICON_SORTER = proc do |a, b|
      ma = a.scan ICON_REGEX
      mb = b.scan ICON_REGEX

      if ma.first && mb.first
        mb.first.first.to_i <=> ma.first.first.to_i
      elsif ma.first && !mb.first
        1
      elsif !ma.first && ma.first
        -1
      else
        a <=> b
      end
    end

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
      self.append = true
      self.transient = false
    end
    private :set_defaults

    # Shows a notification.
    #
    # @see Libnotify.show
    def show!
      notify_init(self.class.to_s) or raise "notify_init failed"
      notify = notify_notification_new(summary, body, icon_path, nil)
      notify_notification_set_urgency(notify, lookup_urgency(urgency))
      notify_notification_set_timeout(notify, timeout || -1)
      if append
        notify_notification_set_hint_string(notify, "x-canonical-append", "")
        notify_notification_set_hint_string(notify, "append", "")
      end
      if transient
        notify_notification_set_hint_uint32(notify, "transient", 1)
      end
      notify_notification_show(notify, nil)
    ensure
      notify_notification_clear_hints(notify) if (append || transient)
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

    # Sets icon path.
    #
    # Path can be absolute, relative (will be resolved) or an symbol.
    #
    # @todo document and refactor
    def icon_path=(path)
      case path
      when /^\// # absolute
        @icon_path = path
      when String
        list = self.class.icon_dirs.map { |d| Dir[File.join(d, path)] }.flatten.sort(&ICON_SORTER)
        @icon_path = list.detect { |full_path| File.exist?(full_path) } || path
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

  end
end
