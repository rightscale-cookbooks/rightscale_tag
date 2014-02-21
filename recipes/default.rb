#
# Cookbook Name:: rightscale_tag
# Recipe:: default
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

marker "recipe_start_rightscale" do
  template "rightscale_audit_entry.erb"
end

include_recipe 'machine_tag'

if node['rightscale'] && node['rightscale']['instance_uuid']
  machine_tag "server:uuid=#{node['rightscale']['instance_uuid']}"
end

if node['cloud']
  if node['cloud']['public_ips']
    node['cloud']['public_ips'].reject { |ip| ip.nil? || ip.empty? }.each_with_index do |public_ip, index|
      machine_tag "server:public_ip_#{index}=#{public_ip}"
    end
  end

  if node['cloud']['private_ips']
    node['cloud']['private_ips'].reject { |ip| ip.nil? || ip.empty? }.each_with_index do |private_ip, index|
      machine_tag "server:private_ip_#{index}=#{private_ip}"
    end
  end
end
