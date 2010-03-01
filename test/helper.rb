require 'rubygems'
require 'riot'
require 'riot/rr'
require 'riot_notifier'

require 'libnotify'

Riot.reporter = RiotNotifier
