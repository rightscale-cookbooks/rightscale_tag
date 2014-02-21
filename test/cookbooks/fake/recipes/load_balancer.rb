#
# Cookbook Name:: fake
# Recipe:: load_balancer
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

# Load balancer setup. We are only using api and not both api and www so the latter doesn't pollute the tag data
rightscale_tag_load_balancer 'api server' do
  application_name 'api'
  action :create
end

# Use find_load_balancer_servers helper method and write it to a JSON file so the kitchen tests can access it

class Chef::Resource::RubyBlock
  include Rightscale::RightscaleTag
end

ruby_block "Find load balancer servers" do
  block do
    File.open("/tmp/found_lb_servers.json", "w") do |file|
      file.write find_load_balancer_servers(node, "api").to_json
    end
  end
end
