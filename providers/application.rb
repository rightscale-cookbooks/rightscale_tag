#
# Cookbook Name:: rightscale_tag
# Provider:: application
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

# The create action that creates required tags for an application server
action :create do
  [
    'application:active=true',
    "application:active_#{new_resource.application_name}=true",
    "application:bind_ip_address_#{new_resource.application_name}=#{new_resource.bind_ip_address}",
    "application:bind_port_#{new_resource.application_name}=#{new_resource.bind_port}",
    "application:vhost_path_#{new_resource.application_name}=#{new_resource.vhost_path}",
  ].each do |tag|
    machine_tag tag
  end

  new_resource.updated_by_last_action(true)
end

# The delete action that removes the application specific tags from the server
action :delete do
  [
    'application:active=true',
    "application:active_#{new_resource.application_name}=true",
    "application:bind_ip_address_#{new_resource.application_name}=#{new_resource.bind_ip_address}",
    "application:bind_port_#{new_resource.application_name}=#{new_resource.bind_port}",
    "application:vhost_path_#{new_resource.application_name}=#{new_resource.vhost_path}",
  ].each do |tag|
    machine_tag tag do
      action :delete
    end
  end

  new_resource.updated_by_last_action(true)
end
