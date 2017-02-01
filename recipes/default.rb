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

require 'ipaddress'
marker 'recipe_start_rightscale' do
  template 'rightscale_audit_entry.erb'
end

include_recipe 'machine_tag'

if node['rightscale'] && node['rightscale']['instance_uuid']
  machine_tag "server:uuid=#{node['rightscale']['instance_uuid']}"
end

ip_addr = node['ipaddress']
if node['cloud']
  if node['cloud']['public_ips'] && !node['cloud']['public_ips'].first.nil?
    node['cloud']['public_ips'].reject { |ip| ip.nil? || ip.empty? || IPAddress(ip).private? }.each_with_index do |public_ip, index|
      machine_tag "server:public_ip_#{index}=#{public_ip}"
    end
  elsif node['cloud_v2']
    if node['cloud_v2']['public_ipv4_addrs']
      node['cloud_v2']['public_ipv4_addrs'].reject { |ip| ip.nil? || ip.empty? || IPAddress(ip).private? }.each_with_index do |public_ip, index|
        machine_tag "server:public_ip_#{index}=#{public_ip}"
      end
    end
  else
    machine_tag "server:public_ip_0=#{ip_addr}" unless IPAddress(ip_addr).private?
  end

  if node['cloud']['private_ips'] && !node['cloud']['private_ips'].first.nil?
    node['cloud']['private_ips'].reject { |ip| ip.nil? || ip.empty? || !IPAddress(ip).private? }.each_with_index do |private_ip, index|
      machine_tag "server:private_ip_#{index}=#{private_ip}"
    end
  elsif node['cloud_v2']
    if node['cloud_v2']['local_ipv4_addrs']
      node['cloud_v2']['local_ipv4_addrs'].reject { |ip| ip.nil? || ip.empty? || !IPAddress(ip).private? }.each_with_index do |private_ip, index|
        machine_tag "server:private_ip_#{index}=#{private_ip}"
      end
    end
  elsif IPAddress(ip_addr).private?
    machine_tag "server:private_ip_0=#{ip_addr}"
  end
end
