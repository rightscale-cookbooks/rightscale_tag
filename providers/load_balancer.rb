#
# Cookbook Name:: rightscale_tag
# Provider:: load_balancer
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

# The create action that creates required tags for a load balancer server
action :create do
  machine_tag ::MachineTag::Tag.machine_tag('load_balancer', "active_#{new_resource.application_name}", true)
  new_resource.updated_by_last_action(true)
end

# The delete action that removes the load balancer specific tags from the server
action :delete do
  machine_tag ::MachineTag::Tag.machine_tag('load_balancer', "active_#{new_resource.application_name}", true) do
    action :delete
  end
  new_resource.updated_by_last_action(true)
end
