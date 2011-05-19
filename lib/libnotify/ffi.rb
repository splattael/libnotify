module Libnotify
  # Raw FFI bindings.
  module FFI
    require 'ffi'
    extend ::FFI::Library

    def self.included(base)
      ffi_lib %w[libnotify libnotify.so libnotify.so.1]
      attach_functions!
    rescue LoadError => e
      warn e.message
    end

    URGENCY = [ :low, :normal, :critical ]

    def self.attach_functions!
      attach_function :notify_init,                         [:string],                              :bool
      attach_function :notify_uninit,                       [],                                     :void
      attach_function :notify_notification_new,             [:string, :string, :string, :pointer],  :pointer
      attach_function :notify_notification_set_urgency,     [:pointer, :int],                       :void
      attach_function :notify_notification_set_timeout,     [:pointer, :long],                      :void
      attach_function :notify_notification_set_hint_string, [:pointer, :string, :string],           :void
      attach_function :notify_notification_clear_hints,     [:pointer],                             :void
      attach_function :notify_notification_show,            [:pointer, :pointer],                   :bool
    end

    def lookup_urgency(urgency)
      URGENCY.index(urgency)
    end

    def method_missing(method, *args, &block)
      if method.to_s =~ /^notify_/
        warn "libnotify.so not found!"
      end

      super
    end
  end
end
