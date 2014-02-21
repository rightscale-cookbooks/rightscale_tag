#
# Cookbook Name:: rightscale_tag
# Resource:: load_balancer
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

# The name of the application the load balancer will serve
attribute :application_name, :kind_of => String, :name_attribute => true

# Creates the required tags for the load balancer server
actions :create

# Removes the tags from the load balancer server
actions :delete

# The default action is :create
default_action :create
