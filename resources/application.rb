#
# Cookbook Name:: rightscale_tag
# Resource:: application
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

# The name of the application
attribute :application_name, :kind_of => String, :name_attribute => true

# The bind IP address of the application
attribute :bind_ip_address, :kind_of => String, :required => true, :callbacks => {
  'should be a valid IP address' => lambda do |ip_address|
    require 'ipaddress'
    begin
      IPAddress.parse(ip_address)
      true
    rescue ArgumentError
      false
    end
  end
}

# The bind port of the application
attribute :bind_port, :kind_of => Fixnum, :required => true

# The vhost path of the application. Examples: `'api.example.com'`, `'/api'`
attribute :vhost_path, :kind_of => String, :required => true

# Creates the required tags for the application server
actions :create

# Removes the tags from the application server
actions :delete

# The default action is :create
default_action :create
