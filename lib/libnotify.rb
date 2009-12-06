

require 'rubygems'
require 'ffi'

module Libnotify

  def self.new(*args, &block)
    API.new(*args, &block)
  end

  def self.show(*args, &block)
    API.show(*args, &block)
  end

  module FFI
    extend ::FFI::Library

    ffi_lib 'libnotify'

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
    attr_accessor :name, :summary, :body, :icon_path, :timeout, :urgency

    def initialize(options = {}, &block)
      self.summary = self.body = " "
      self.urgency = :normal
      self.timeout = nil
      options.each { |key, value| send("#{key}=", value) if respond_to?(key) }
      yield(self) if block_given?
    end

    def self.show(*args, &block)
      new(*args, &block).show!
    end

    def show!
      notify_init(self.class.to_s) or raise "notify_init failed"
      notify = FFI.notify_notification_new(summary, body, icon_path, nil)
      notify_notification_set_urgency(notify, urgency)
      notify_notification_set_timeout(notify, timeout)
      notify_notification_show(notify, nil)
    ensure
      notify_uninit
    end

    def timeout=(timeout)
      @timeout = case timeout
      when NilClass, FalseClass
        -1
      when Float
        (timeout * 1000).to_i
      when Fixnum
        if timeout > 100 # assume miliseconds
          timeout
        else
          timeout * 1000
        end
      else
        timeout.to_i
      end
    end
  end

end

if $0 == __FILE__
  Libnotify.new do |notify|
    notify.summary = "world"
    notify.body = "hello"
    notify.timeout = 1.5        # or 1000ms, nil, false
    notify.urgency = :critical  # or :low, :normal, :critical
    notify.icon_path = "/usr/share/icons/gnome/scalable/emblems/emblem-default.svg"
    notify.show!
  end

  Libnotify.show(:body => "hello", :summary => "world", :timeout => 2.5)
end
