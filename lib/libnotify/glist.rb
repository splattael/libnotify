module Libnotify
  module FFI
    # Represents a linked list of strings.
    #
    # @see https://developer.gnome.org/glib/unstable/glib-Doubly-Linked-Lists.html#GList
    class Glist < ::FFI::Struct
      include Enumerable

      layout \
        :data, :string,
        :next, self.by_ref,
        :prev, self.by_ref

      # Yields element's content.
      #
      # @yield String
      def each
        element = self
        loop do
          yield element[:data]
          break if element[:next].null?
          element = element[:next]
        end
      end

      alias :inspect :to_a
    end
  end
end
