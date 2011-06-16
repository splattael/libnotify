class LibnotifyIO
  attr_reader :io, :libnotify

  def initialize io
    @io = io
    @libnotify = begin
      require 'libnotify'
      Libnotify.new(:timeout => 2.5, :append => false)
    end
  end

  def puts *o
    if o.first =~ /(\d+) failures, (\d+) errors/
      description = [ defined?(RUBY_ENGINE) ? RUBY_ENGINE : "ruby", RUBY_VERSION, RUBY_PLATFORM ].join(" ")
      libnotify.body = o.first
      if $1.to_i > 0 || $2.to_i > 0 # fail?
        libnotify.summary = ":-( #{description}"
        libnotify.urgency = :critical
        libnotify.icon_path = "face-angry.*"
      else
        libnotify.summary += ":-) #{description}"
        libnotify.urgency = :normal
        libnotify.icon_path = "face-laugh.*"
      end
      libnotify.show!
    else
      io.puts *o
    end
  end

  def method_missing msg, *args
    io.send(msg, *args)
  end
end

MiniTest::Unit.output = LibnotifyIO.new(MiniTest::Unit.output)
