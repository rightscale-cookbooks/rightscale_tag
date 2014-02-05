#
# Cookbook Name:: rightscale_tag
# Helper:: rightscale_tag_helper
#
# Copyright (C) 2014 RightScale, Inc.
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

class Chef
  module RightscaleTag
    # Finds all load balancers if no name is given and finds
    # load balancers matching the application_name if the application_name
    # is given. The options hash is passed to the underlying machine_tag
    # resource
    #
    # @param node
    # @param application_name
    #
    # @option options [Integer] :query_timeout (120) the seconds to timeout for the query operation
    #
    # @return [Hash] Information about all matching load balancer servers
    #
    # @see http://rubydoc.info/gems/machine_tag/#MachineTag__Set MachineTag::Set
    #
    # @example Example Hash output
    #
    #     {
    #       'UUID-1': {
    #         'tags': MachineTag::Set,
    #         'application_names': [],
    #         'private_ips': [],
    #         'public_ips': []
    #       }
    #     }
    #
    def find_load_balancer_servers(node, application_name = nil, options = {})
      required_tags(options)

      if application_name
        query_tag = ::MachineTag::Tag.machine_tag('load_balancer', "active_#{application_name}", true)
      else
        query_tag = 'load_balancer:'
      end

      servers = tag_search(node, query_tag, options)

      unless application_name
        servers.reject! do |tags|
          tags[/^load_balancer:active_.+$/].empty?
        end
      end

      build_server_hash(servers) do |tags|
        #
      end
    end

    # Finds all application servers if no application name is given and finds
    # application servers matching the application_name if the application_name
    # is given.
    #
    # @param node
    # @param application_name
    #
    # @option options [Integer] :query_timeout (120) the seconds to timeout for the query operation
    #
    # @return [Hash] Information about all matching application servers
    #
    # @see http://rubydoc.info/gems/machine_tag/#MachineTag__Set MachineTag::Set
    #
    # @example Example Hash output
    #
    #     {
    #       'UUID-1': {
    #         'tags': MachineTag::Set,
    #         'applications': {
    #           'APP-1': {
    #             'bind_address': 'IP:PORT',
    #             'ip': 'IP',
    #             'port': 'PORT',
    #             'vhost_path': 'VHOST_PATH',
    #           }
    #         },
    #         'private_ips': [],
    #         'public_ips': []
    #       }
    #     }
    #
    #
    def find_application_servers(node, application_name = nil, options = {})
      required_tags(options)

      if application_name
        query_tag = ::MachineTag::Tag.machine_tag('application', "active_#{application_name}", true)
        required_tags(options,
          ::MachineTag::Tag.machine_tag('application', "bind_ip_address_#{application_name}", '*'),
          ::MachineTag::Tag.machine_tag('application', "bind_port_#{application_name}", '*'),
          ::MachineTag::Tag.machine_tag('application', "vhost_path_#{application_name}", '*')
        )
      else
        query_tag = 'application:'
      end

      servers = tag_search(node, query_tag, options)

      unless application_name
        servers.reject! do |tags|
          tags[/^application:active_.+$/].empty?
        end
      end

      build_server_hash(servers) do |tags|
        #
      end
    end

    #
    # @param node
    # @param lineage [String] the lineage used to filter database servers
    # @param role [Symbol] the role to filter. Valid values are `:master` and `:slave`
    #
    # @option options [Integer] :query_timeout (120) the seconds to timeout for the query operation
    #
    # @return [Hash] Information about all matching database servers
    #
    # @see http://rubydoc.info/gems/machine_tag/#MachineTag__Set MachineTag::Set
    #
    # @example Example Hash Output
    #
    #     {
    #       'UUID-1': {
    #         'tags': MachineTag::Set,
    #         'lineage': 'LINEAGE',
    #         'role': 'ROLE',
    #         'master_since': Time, # Only for master servers
    #         'slave_since': Time,  # Only for slave servers
    #         'private_ips': [],
    #         'public_ips': []
    #       }
    #     }
    #
    def find_database_servers(node, lineage = nil, role = nil, options = {})
      required_tags(options)

      if role
        query_tag = ::MachineTag::Tag.machine_tag('database', "#{role}_active", '*')
        required_tags(options, ::MachineTag::Tag.machine_tag('database', 'active', true))
      else
        query_tag = ::MachineTag::Tag.machine_tag('database', 'active', true)
      end
      required_tags(options, ::MachineTag::Tag.machine_tag('database', 'lineage', '*'))

      servers = tag_search(node, query_tag, options)

      if lineage
        servers.reject! do |tags|
          !tags.include?(::MachineTag::Tag.machine_tag('database', 'lineage', lineage))
        end
      end

      build_server_hash(servers) do |tags|
        #
      end
    end

    private

    def required_tags(options, *tags)
      require 'set'

      options[:required_tags] ||= Set['server:uuid']
      options[:required_tags] += tags
    end

    def build_server_hash(servers, &block)
      #
    end
  end
end
