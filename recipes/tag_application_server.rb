# frozen_string_literal: true
#
# Cookbook Name:: rightscale_tag
# Recipe:: tag_server
#
# Copyright (C) 2017 RightScale, Inc.
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

marker 'recipe_start_rightscale' do
  template 'rightscale_audit_entry.erb'
end

include_recipe 'rightscale_tag::default'

# Set up application server tags
rightscale_tag_application node['rightscale_tag']['application_name'] do
  bind_ip_address private_ip?
  bind_port node['rightscale_tag']['listen_port'].to_i
  vhost_path node['rightscale_tag']['vhost_path']
  action :create
end

def private_ip?
  ip_addr = node['ipaddress']
  private_ip = nil
  if node['cloud']['private_ips'] && !node['cloud']['private_ips'].first.nil?
    node['cloud']['private_ips'].reject { |ip| ip.nil? || ip.empty? || !IPAddress(ip).private? }.each_with_index do |private_ip, index|
      private_ip="#{private_ip}"
    end
  elsif node['cloud_v2']
    if node['cloud_v2']['local_ipv4_addrs']
      node['cloud_v2']['local_ipv4_addrs'].reject { |ip| ip.nil? || ip.empty? || !IPAddress(ip).private? }.each_with_index do |private_ip, index|
        private_ip="#{private_ip}"
      end
    end
  elsif IPAddress(ip_addr).private?
    private_ip = ip_addr
  end
  return private_ip
end
