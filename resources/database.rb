#
# Cookbook Name:: rightscale_tag
# Resource:: database
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

# The role of the database server. This attribute should only contain alphanumeric characters and underscores and
# should start with a letter.
#
attribute :role, :kind_of => String, :regex => /^[a-z][a-z0-9_]*$/i, :name_attribute => true

# The lineage of the database server
attribute :lineage, :kind_of => String

# The timestamp used to create the <role>_active tag. This tag represents that the server is in the specified role
# since this timestamp
attribute :timestamp, :kind_of => Fixnum

# Creates the required tags for the database server
actions :create

# Removes the tags from the database server
actions :delete

# The default action is :create
default_action :create
