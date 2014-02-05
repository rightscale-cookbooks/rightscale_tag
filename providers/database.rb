#
# Cookbook Name:: rightscale_tag
# Provider:: database
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

# The create action that creates required tags for a database server
action :create do
  [
    "database:active=true",
    "database:lineage=#{new_resource.lineage}",
    "database:#{new_resource.role}_active=#{new_resource.timestamp}"
  ].each do |tag|
    machine_tag tag
  end
end

# The delete action that removes the database specific tags from the server
action :delete do
  [
    "database:active=true",
    "database:lineage=#{new_resource.lineage}",
    "database:#{new_resource.role}_active=#{new_resource.timestamp}"
  ].each do |tag|
    machine_tag tag do
      action :delete
    end
  end
end
