#
# Cookbook Name:: rightscale_tag
# Resource:: database
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

# The lineage of the database server
attribute :lineage, :kind_of => String, :name_attribute => true

# The bind IP address of the database
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

# The bind port of the database
attribute :bind_port, :kind_of => Fixnum, :required => true

# The role of the database server. This attribute should only contain alphanumeric characters and underscores and
# should start with a letter.
#
attribute :role, :kind_of => String, :regex => /^[a-z][a-z0-9_]*$/i

# Creates the required tags for the database server
actions :create

# Removes the tags from the database server
actions :delete

# The default action is :create
default_action :create
