require 'ffi'

# Ruby bindings for libnotify using FFI.
#
# See README.rdoc for usage examples.
module Libnotify

  def self.new(*args, &block)
    API.new(*args, &block)
  end

  def self.show(*args, &block)
    API.show(*args, &block)
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

    def initialize(options = {}, &block)
      set_defaults
      options.each { |key, value| send("#{key}=", value) if respond_to?(key) }
      yield(self) if block_given?
    end

    def set_defaults
      # TODO Empty strings give warnings
      self.summary = self.body = " "
      self.urgency = :normal
      self.timeout = nil
    end
    private :set_defaults

    def show!
      notify_init(self.class.to_s) or raise "notify_init failed"
      notify = notify_notification_new(summary, body, icon_path, nil)
      notify_notification_set_urgency(notify, urgency)
      notify_notification_set_timeout(notify, timeout || -1)
      notify_notification_show(notify, nil)
    ensure
      notify_uninit
    end

    def timeout=(timeout)
      # TODO Simplify timeout=
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

    def self.show(*args, &block)
      new(*args, &block).show!
    end

  end

end
