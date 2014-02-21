#
# Cookbook Name:: fake
# Recipe:: application
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

rightscale_tag_application 'www' do
  bind_ip_address '10.0.0.1'
  bind_port 8080
  vhost_path 'www.example.com'
  action :create
end

# Use find_application_servers helper method and write it to a JSON file so the kitchen test can access it

class Chef::Resource::RubyBlock
  include Rightscale::RightscaleTag
end

ruby_block "Find application servers" do
  block do
    ::File.open("/tmp/found_app_servers.json", "w") do |file|
      file.write find_application_servers(node, "www").to_json
    end
  end
end
