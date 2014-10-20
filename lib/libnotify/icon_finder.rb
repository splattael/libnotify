module Libnotify
  class IconFinder
    def initialize(dirs)
      @dirs = dirs
    end

    def icon_path(name)
      list = @dirs.map do |dir|
        glob = File.join(dir, name)
        Dir[glob].map { |fullpath| Icon.new(fullpath) }
      end
      if found = list.flatten.sort.first
        found.to_s
      end
    end

    class Icon
      attr_reader :fullpath

      def initialize(fullpath)
        @fullpath = fullpath
      end

      ICON_REGEX = /(\d+)x\d+/
      def resolution
        @resolution ||= @fullpath[ICON_REGEX, 1].to_i
      end

      def to_s
        fullpath
      end

      def <=>(other)
        result = other.resolution <=> self.resolution
        result = self.fullpath    <=> other.fullpath if result == 0
        result
      end
    end
  end
end
