#
# Cookbook Name:: fake
# Recipe:: database
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

# Database setup
rightscale_tag_database 'production' do
  bind_ip_address '10.0.0.2'
  bind_port 3306
  role 'master'
  action :create
end

# Use the find_database_servers helper method and write it to a JSON file so the kitchen tests can access it

class Chef::Resource::RubyBlock
  include Rightscale::RightscaleTag
end

ruby_block "Find database servers" do
  block do
    File.open("/tmp/found_db_servers.json", "w") do |file|
      file.write find_database_servers(node, "production").to_json
    end
  end
end
