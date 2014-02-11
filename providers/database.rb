#
# Cookbook Name:: rightscale_tag
# Provider:: database
#
# Copyright (C) 2013 RightScale, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# The create action that creates required tags for a database server
action :create do
  require 'machine_tag'

  database_tags = [
    ::MachineTag::Tag.machine_tag('database', 'active', true),
    ::MachineTag::Tag.machine_tag('database', 'lineage', new_resource.lineage),
    ::MachineTag::Tag.machine_tag('database', 'bind_ip_address', new_resource.bind_ip_address),
    ::MachineTag::Tag.machine_tag('database', 'bind_port', new_resource.bind_port),
  ]
  if new_resource.role
    timestamp_file = "/var/lib/rightscale/rightscale_tag_database_#{new_resource.role}_active.timestamp"
    if ::File.exists?(timestamp_file)
      timestamp = ::Time.at(::File.read(timestamp_file).to_i)
    else
      timestamp = ::Time.now
    end

    directory '/var/lib/rightscale' do
      mode 0755
    end

    file timestamp_file do
      action :create_if_missing
      content timestamp.to_i.to_s
    end

    database_tags << "database:#{new_resource.role}_active=#{timestamp.to_i}"
  end

  database_tags.each do |tag|
    machine_tag tag
  end
  new_resource.updated_by_last_action(true)
end

# The delete action that removes the database specific tags from the server
action :delete do
  require 'machine_tag'

  database_tags = [
    ::MachineTag::Tag.machine_tag('database', 'active', true),
    ::MachineTag::Tag.machine_tag('database', 'lineage', new_resource.lineage),
    ::MachineTag::Tag.machine_tag('database', 'bind_ip_address', new_resource.bind_ip_address),
    ::MachineTag::Tag.machine_tag('database', 'bind_port', new_resource.bind_port),
  ]
  if new_resource.role
    timestamp_file = "/var/lib/rightscale/rightscale_tag_database_#{new_resource.role}_active.timestamp"
    if ::File.exists?(timestamp_file)
      timestamp = ::Time.at(::File.read(timestamp_file).to_i)
    else
      timestamp = 0
    end

    file timestamp_file do
      action :delete
    end

    database_tags << "database:#{new_resource.role}_active=#{timestamp.to_i}"
  end

  database_tags.each do |tag|
    machine_tag tag do
      action :delete
    end
  end
  new_resource.updated_by_last_action(true)
end