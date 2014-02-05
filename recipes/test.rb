#
# Cookbook Name:: rightscale_tag
# Recipe:: test
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

delete = false

marker "recipe_start_rightscale" do
  template "rightscale_audit_entry.erb"
end

## Database
rightscale_tag_database 'master' do
  lineage 'production'
  timestamp 1391473172
  action delete == true ? :delete : :create
end

## Application

rightscale_tag_application 'www' do
  bind_ip_address '10.0.0.1'
  bind_port 8080
  vhost_path 'www.example.com'
  action delete == true ? :delete : :create
end

rightscale_tag_application 'api server' do
  application_name 'api'
  bind_ip_address '10.0.0.2'
  bind_port 80
  vhost_path '/api'
  action delete == true ? :delete : :create
end

## Load Balancer
rightscale_tag_load_balancer 'www' do
  action delete == true ? :delete : :create
end

rightscale_tag_load_balancer 'api server' do
  application_name 'api'
  action delete == true ? :delete : :create
end
