#!/usr/bin/env ruby
# frozen_string_literal: true

# Export one provider with one account, the way a sync client does.
#
# Two things are needed and only one of them is D-Bus. The exporter puts the
# provider on the session bus, and a key file under cloud-providers/ in one of
# XDG_DATA_DIRS tells the file manager that the bus name is worth looking at.
# Without the key file nothing ever asks, however correct the export is --
# libcloudproviders' collector reads g_get_system_data_dirs(), so XDG_DATA_HOME
# is NOT searched.
#
#   ruby examples/export_provider.rb
#
# Then, in another terminal with the same XDG_DATA_DIRS:
#
#   ruby examples/list_providers.rb

require "fileutils"
require "tmpdir"

BUS_NAME = "org.example.RubyCloud"
OBJECT_PATH = "/org/example/RubyCloud"

# The key file has to be in place before the collector looks, so it is written
# first and XDG_DATA_DIRS is extended before GLib reads it.
data_dir = File.join(Dir.tmpdir, "libcloudproviders-rb-example")
FileUtils.mkdir_p(File.join(data_dir, "cloud-providers"))
File.write(File.join(data_dir, "cloud-providers", "ruby-cloud.ini"), <<~INI)
  [Cloud Providers]
  BusName=#{BUS_NAME}
  ObjectPath=#{OBJECT_PATH}
INI

ENV["XDG_DATA_DIRS"] = [data_dir, ENV.fetch("XDG_DATA_DIRS", "/usr/local/share:/usr/share")].join(":")
puts "key file: #{File.join(data_dir, "cloud-providers", "ruby-cloud.ini")}"
puts "XDG_DATA_DIRS now starts with #{data_dir}"

require "gio2"
require "libcloudproviders"

# Owned before the exporter publishes, or there is nothing for the collector to
# acquire when it follows the key file.
Gio.bus_own_name(Gio::BusType::SESSION, BUS_NAME, Gio::BusNameOwnerFlags::NONE)

connection = Gio.bus_get_sync(Gio::BusType::SESSION)
provider = CloudProviders::ProviderExporter.new(connection, BUS_NAME, OBJECT_PATH)
provider.set_name("Ruby Cloud")

# The account is what the file manager draws, one sidebar row each, and the row
# is labelled with the ACCOUNT's name -- not the provider's. Setting the
# provider's name alone leaves the row reading whatever the account is called,
# which is why this one is named for the service rather than for a user.
#
# So the row count is the account count. Export one account and you get one
# row, however many things are actually being synced behind it; export one per
# user and the sidebar reads as that many separate clouds.
#
# The name passed to the constructor becomes an object path segment, so it has
# to be a valid one; the label is the name= below.
account = CloudProviders::AccountExporter.new(provider, "ruby_cloud")
account.name = "Ruby Cloud"
# Path must be a real directory: the file manager builds "file://" plus Path.
account.path = Dir.home
# A file beside the example rather than a themed name: a themed name only
# resolves if the icon is installed into a theme the file manager searches, and
# a client shipping its own brand icon has a file. Gio::ThemedIcon.new("folder-remote")
# works too where the theme has it.
account.icon = Gio::FileIcon.new(Gio::File.new_for_path(File.expand_path("ruby-cloud.png", __dir__)))
account.set_status(CloudProviders::AccountStatus::SYNCING)
account.set_status_details("Syncing 3 of 12")

# The context menu the file manager shows on the row. Actions are looked up in
# the group the account exports, under the "cloudprovider" prefix.
actions = Gio::SimpleActionGroup.new
open = Gio::SimpleAction.new("open")
open.signal_connect("activate") { puts "open was clicked" }
actions.add_action(open)
account.action_group = actions

menu = Gio::Menu.new
menu.append("Open", "cloudprovider.open")
account.menu_model = menu

puts "exported #{BUS_NAME} #{OBJECT_PATH} -- ctrl-c to stop"
GLib::MainLoop.new(nil, false).run
