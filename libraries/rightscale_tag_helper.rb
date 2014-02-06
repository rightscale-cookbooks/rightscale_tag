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

      servers = Chef::MachineTagHelper.tag_search(node, query_tag, options)

      unless application_name
        servers.reject! do |tags|
          tags[/^load_balancer:active_.+$/].empty?
        end
      end

      build_server_hash(servers) do |tags|
        application_names = tags[/^load_balancer:active_.+$/].map do |tag|
          next if tag.value != 'true'
          tag.predicate.gsub(/^active_/, '')
        end

        {'application_names' => application_names.compact}
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
    #             'bind_ip_address': 'IP',
    #             'bind_port': PORT,
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

      servers = Chef::MachineTagHelper.tag_search(node, query_tag, options)

      unless application_name
        servers.reject! do |tags|
          tags[/^application:active_.+$/].empty?
        end
      end

      build_server_hash(servers) do |tags|
        application_hashes = tags[/^application:active_.+$/].map do |tag|
          next if tag.value != 'true'
          application_name = tag.predicate.gsub(/^active_/, '')
          application_hash = {}

          bind_ip_address = tags['application', "bind_ip_address_#{application_name}"].first
          bind_port = tags['application', "bind_port_#{application_name}"].first
          vhost_path = tags['application', "vhost_path_#{application_name}"].first

          application_hash['bind_ip_address'] = bind_ip_address.value if  bind_ip_address
          application_hash['bind_port'] = bind_port.value.to_i if bind_port
          application_hash['vhost_path'] = vhost_path.value if vhost_path

          [application_name, application_hash]
        end

        {'applications' => Hash[application_hashes.compact]}
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

      servers = Chef::MachineTagHelper.tag_search(node, query_tag, options)

      if lineage
        servers.reject! do |tags|
          !tags.include?(::MachineTag::Tag.machine_tag('database', 'lineage', lineage))
        end
      end

      build_server_hash(servers) do |tags|
        server_hash = {'lineage' => tags['database:lineage'].first.value}
        master_active = tags['database:master_active'].first
        slave_active = tags['database:slave_active'].first

        if master_active && slave_active
          master_since = Time.at(master_active.value.to_i)
          slave_since = Time.at(slave_active.value.to_i)

          if master_since >= slave_since
            server_hash['role'] = 'master'
            server_hash['master_since'] = master_since
          else
            server_hash['role'] = 'slave'
            server_hash['slave_since]'] = slave_since
          end
        elsif master_active
          server_hash['role'] = 'master'
          server_hash['master_since'] = Time.at(master_active.value.to_i)
        elsif slave_active
          server_hash['role'] = 'slave'
          server_hash['slave_since'] = Time.at(slave_active.value.to_i)
        end

        server_hash
      end
    end

    private

    # Adds required tags to the options for Chef::MachineTagHelper#tag_search that are needed for the various
    # `find_*_servers` methods. By default it will add `server:uuid`, any other requirements need to be passed
    # as additional arguments. This method can be called multiple times to add further tag requirements.
    #
    # @param options [Hash] the options hash to populate
    # @param tags [Array<String>] the required tags
    #
    def required_tags(options, *tags)
      require 'set'

      options[:required_tags] ||= Set['server:uuid']
      options[:required_tags] += tags
    end

    # Builds an array of server information hashes to be returned by the `find_*_servers` methods. A callback
    # block can be passed to further populate each server information hash from each tag set.
    #
    # @param servers [Array<MachineTag::Set>] the array of tag sets returned by Chef::MachineTagHelper#tag_search
    # @param block [Proc(MachineTag::Set)] a block that does further processing on each tag set; it should
    #   return a hash that will be merged into the server information hash
    #
    def build_server_hash(servers, &block)
      server_hashes = servers.map do |tags|
        uuid = tags['server:uuid'].first.value
        server_hash = {
          'tags' => tags,
          'public_ips' => tags[/^server:public_ip_\d+$/].map { |tag| tag.value },
          'private_ips' => tags[/^server:private_ip_\d+$/].map { |tag| tag.value },
        }

        server_hash.merge!(block.call(tags)) if block

        [uuid, server_hash]
      end

      Hash[server_hashes]
    end
  end
end
