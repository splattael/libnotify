require 'rubygems'
require 'riot'
require 'riot_notifier'

require 'libnotify'

Riot.reporter = RiotNotifier

require 'rr'

Riot::Situation.send :include, RR::Adapters::RRMethods
