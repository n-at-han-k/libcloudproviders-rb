#!/usr/bin/env ruby
# frozen_string_literal: true

# The file manager's side: what the collector finds.
#
# Run examples/export_provider.rb first, and run this with the same
# XDG_DATA_DIRS it printed, or the key file is not on the search path and
# nothing is found.
#
#   XDG_DATA_DIRS=/tmp/libcloudproviders-rb-example:$XDG_DATA_DIRS \
#     ruby examples/list_providers.rb

require "libcloudproviders"

collector = CloudProviders::Collector.dup_singleton

# No #update call: libcloudproviders 0.4.0 declares cloud_providers_collector_update
# in its typelib but does not export the symbol, so calling it raises. The
# collector reads the key files when it is constructed.
#
# It then acquires the named providers asynchronously, so the loop is given a
# moment to settle before anything is read.
loop_ = GLib::MainLoop.new(nil, false)
GLib::Timeout.add(1500) { loop_.quit; false }
loop_.run

providers = collector.providers
puts "providers: #{providers.length}"

providers.each do |provider|
  puts "- #{provider.name}"

  provider.accounts.each do |account|
    puts "    #{account.name}"
    puts "      path:    #{account.path}"
    puts "      status:  #{account.status}"
    puts "      details: #{account.status_details}"
  end
end

puts "nothing found -- is the key file on XDG_DATA_DIRS, and is the exporter running?" if providers.empty?
