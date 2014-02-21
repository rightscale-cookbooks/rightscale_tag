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

module Rightscale
  module RightscaleTag
    # Find load balancer servers using tags. This will find all active load balancer servers, or, if
    # `application_name` is given, it will find all load balancer servers serving for that application.
    #
    # @param node [Chef::Node] the Chef node
    # @param application_name [String, nil] the name of the application served by load balancer servers
    #   to search for
    #
    # @option options [Integer] :query_timeout (120) the seconds to timeout for the query operation
    #
    # @return [Mash] a hash with server UUIDs as keys and server information hashes as values
    #
    # @see http://rubydoc.info/gems/machine_tag/#MachineTag__Set MachineTag::Set
    #
    # @example Example server hash
    #
    #     {
    #       '01-ABCDEF123456' => {
    #         'tags' => MachineTag::Set[
    #           'load_balancer:active=true',
    #           'load_balancer:active_www=true',
    #           'server:public_ip_0=203.0.113.2',
    #           'server:private_ip_0=10.0.0.2',
    #           'server:uuid=01-ABCDEF123456'
    #         ],
    #         'application_names' => ['www'],
    #         'public_ips' => ['203.0.113.2'],
    #         'private_ips' => ['10.0.0.2']
    #       }
    #     }
    #
    def self.find_load_balancer_servers(node, application_name = nil, options = {})
      require 'machine_tag'

      required_tags(options)

      if application_name
        query_tag = ::MachineTag::Tag.machine_tag('load_balancer', "active_#{application_name}", true)
      else
        query_tag = ::MachineTag::Tag.machine_tag('load_balancer', 'active', true)
      end

      # Performs a tag search for load balancer servers with given attributes.
      # See https://github.com/rightscale-cookbooks/machine_tag#tag_searchnode-query-options-- for more information
      # about this helper method.
      servers = Chef::MachineTagHelper.tag_search(node, query_tag, options)

      unless application_name
        servers.reject! do |tags|
          tags[/^load_balancer:active_.+$/].empty?
        end
      end

      # Builds a Hash with server information obtained from each server from their tags.
      build_server_hash(servers) do |tags|
        application_names = tags[/^load_balancer:active_.+$/].map do |tag|
          next if tag.value != 'true'
          tag.predicate.gsub(/^active_/, '')
        end

        {'application_names' => application_names.compact}
      end
    end

    # Find load balancer servers using tags. This will find all active load balancer servers, or, if
    # `application_name` is given, it will find all load balancer servers serving for that application.
    #
    # @param node [Chef::Node] the Chef node
    # @param application_name [String, nil] the name of the application served by load balancer servers
    #   to search for
    #
    # @option options [Integer] :query_timeout (120) the seconds to timeout for the query operation
    #
    # @return [Mash] a hash with server UUIDs as keys and server information hashes as values
    #
    # @see .find_load_balancer_servers
    #
    def find_load_balancer_servers(node, application_name = nil, options = {})
      Rightscale::RightscaleTag.find_load_balancer_servers(node, application_name, options)
    end

    # Find application servers using tags. This will find all active application servers, or, if
    # `application_name` is given, it will find all application servers serving that application.
    #
    # @param node [Chef::Node] the Chef node
    # @param application_name [String, nil] the name of the application served by the application servers
    #   to search for
    #
    # @option options [Integer] :query_timeout (120) the seconds to timeout for the query operation
    #
    # @return [Mash] a hash with server UUIDs as keys and server information hashes as values
    #
    # @see http://rubydoc.info/gems/machine_tag/#MachineTag__Set MachineTag::Set
    #
    # @example Example server hash
    #
    #     {
    #       '01-ABCDEF7890123' => {
    #         'tags' => MachineTag::Set[
    #           'application:active=true',
    #           'application:active_www=true',
    #           'application:bind_ip_address_www=10.0.0.3',
    #           'application:bind_port_www=8080',
    #           'application:vhost_path_www=/',
    #           'server:public_ip_0=203.0.113.3',
    #           'server:private_ip_0=10.0.0.3',
    #           'server:uuid=01-ABCDEF7890123'
    #         ],
    #         'applications' => {
    #           'www' => {
    #             'bind_ip_address' => '10.0.0.3',
    #             'bind_port' => 8080,
    #             'vhost_path' => '/',
    #           }
    #         },
    #         'public_ips' => ['203.0.113.3'],
    #         'private_ips' => ['10.0.0.3']
    #       }
    #     }
    #
    #
    def self.find_application_servers(node, application_name = nil, options = {})
      require 'machine_tag'

      required_tags(options)

      if application_name
        query_tag = ::MachineTag::Tag.machine_tag('application', "active_#{application_name}", true)
        required_tags(options,
          ::MachineTag::Tag.machine_tag('application', "bind_ip_address_#{application_name}", '*'),
          ::MachineTag::Tag.machine_tag('application', "bind_port_#{application_name}", '*'),
          ::MachineTag::Tag.machine_tag('application', "vhost_path_#{application_name}", '*')
        )
      else
        query_tag = ::MachineTag::Tag.machine_tag('application', 'active', true)
      end

      # Performs a tag search for application servers with given attributes.
      # See https://github.com/rightscale-cookbooks/machine_tag#tag_searchnode-query-options-- for more information
      # about this helper method.
      servers = Chef::MachineTagHelper.tag_search(node, query_tag, options)

      unless application_name
        servers.reject! do |tags|
          tags[/^application:active_.+$/].empty?
        end
      end

      # Builds a Hash with server information obtained from each server from their tags.
      build_server_hash(servers) do |tags|
        application_hashes = tags[/^application:active_.+$/].map do |tag|
          next if tag.value != 'true'
          application_name = tag.predicate.gsub(/^active_/, '')
          application_hash = {}

          bind_ip_address = tags['application', "bind_ip_address_#{application_name}"].first
          bind_port = tags['application', "bind_port_#{application_name}"].first
          vhost_path = tags['application', "vhost_path_#{application_name}"].first

          application_hash['bind_ip_address'] = bind_ip_address.value if bind_ip_address
          application_hash['bind_port'] = bind_port.value.to_i if bind_port
          application_hash['vhost_path'] = vhost_path.value if vhost_path

          [application_name, application_hash]
        end

        {'applications' => Hash[application_hashes.compact]}
      end
    end

    # Find application servers using tags. This will find all active application servers, or, if
    # `application_name` is given, it will find all application servers serving that application.
    #
    # @param node [Chef::Node] the Chef node
    # @param application_name [String, nil] the name of the application served by the application servers
    #   to search for
    #
    # @option options [Integer] :query_timeout (120) the seconds to timeout for the query operation
    #
    # @return [Mash] a hash with server UUIDs as keys and server information hashes as values
    #
    # @see .find_application_servers
    #
    def find_application_servers(node, application_name = nil, options = {})
      Rightscale::RightscaleTag.find_application_servers(node, application_name, options)
    end

    # Find database servers using tags. This will find all active database servers, or, if `lineage` is
    # given, it will find all database servers for that linage, or, if `role` is specified it will find
    # the database server(s) with that role.
    #
    # @param node [Chef::Node] the Chef node
    # @param lineage [String] the lineage of the database servers to search for
    # @param role [String] the role of the database servers to search for; this should be `'master'` or
    #   `'slave'`
    #
    # @option options [Boolean] :only_latest_for_role (false) only return the latest server tagged for a role
    # @option options [Integer] :query_timeout (120) the seconds to timeout for the query operation
    #
    # @return [Mash] a hash with server UUIDs as keys and server information hashes as values
    #
    # @see http://rubydoc.info/gems/machine_tag/#MachineTag__Set MachineTag::Set
    #
    # @example Example master server hash
    #
    #     {
    #       '01-ABCDEF4567890' => {
    #         'tags' => MachineTag::Set[
    #           'database:active=true',
    #           'database:master_active=1391803034',
    #           'database:lineage=example',
    #           'server:public_ip_0=203.0.113.4',
    #           'server:private_ip_0=10.0.0.4',
    #           'server:uuid=01-ABCDEF4567890'
    #         ],
    #         'lineage' => 'example',
    #         'bind_ip_address' => '10.0.0.4',
    #         'bind_port' => 3306,
    #         'role' => 'master',
    #         'master_since' => Time.at(1391803034),
    #         'public_ips' => ['203.0.113.4'],
    #         'private_ips' => ['10.0.0.4']
    #       }
    #     }
    #
    # @example Example slave server hash
    #
    #     {
    #       '01-GHIJKL1234567' => {
    #         'tags' => MachineTag::Set[
    #           'database:active=true',
    #           'database:slave_active=1391803892',
    #           'database:lineage=example',
    #           'server:public_ip_0=203.0.113.5',
    #           'server:private_ip_0=10.0.0.5',
    #           'server:uuid=01-GHIJKL1234567'
    #         ],
    #         'lineage' => 'example',
    #         'bind_ip_address' => '10.0.0.5',
    #         'bind_port' => 3306,
    #         'role' => 'slave',
    #         'slave_since' => Time.at(1391803892),
    #         'public_ips' => ['203.0.113.5'],
    #         'private_ips' => ['10.0.0.5']
    #       }
    #     }
    #
    def self.find_database_servers(node, lineage = nil, role = nil, options = {})
      require 'machine_tag'

      only_latest_for_role = options.delete(:only_latest_for_role)
      required_tags(options)

      if role
        query_tag = ::MachineTag::Tag.machine_tag('database', "#{role}_active", '*')
        required_tags(options, ::MachineTag::Tag.machine_tag('database', 'active', true))
      else
        query_tag = ::MachineTag::Tag.machine_tag('database', 'active', true)
      end
      required_tags(options,
        ::MachineTag::Tag.machine_tag('database', 'lineage', '*'),
        ::MachineTag::Tag.machine_tag('database', 'bind_ip_address', '*'),
        ::MachineTag::Tag.machine_tag('database', 'bind_port', '*')
      )

      # Performs a tag search for database servers with given attributes.
      # See https://github.com/rightscale-cookbooks/machine_tag#tag_searchnode-query-options-- for more information
      # about this helper method.
      servers = Chef::MachineTagHelper.tag_search(node, query_tag, options)

      if lineage
        servers.reject! do |tags|
          !tags.include?(::MachineTag::Tag.machine_tag('database', 'lineage', lineage))
        end
      end

      # Builds a Hash with server information obtained from each server from their tags.
      server_hashes = build_server_hash(servers) do |tags|
        server_hash = {
          'lineage' => tags['database:lineage'].first.value,
          'bind_ip_address' => tags['database:bind_ip_address'].first.value,
          'bind_port' => tags['database:bind_port'].first.value.to_i,
        }
        master_active = tags['database:master_active'].first
        slave_active = tags['database:slave_active'].first

        # If a server is identified as both master and slave, pick the most recent role.
        if master_active && slave_active
          master_since = Time.at(master_active.value.to_i)
          slave_since = Time.at(slave_active.value.to_i)

          if master_since >= slave_since
            server_hash['role'] = 'master'
            server_hash['master_since'] = master_since
          else
            server_hash['role'] = 'slave'
            server_hash['slave_since'] = slave_since
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

      # If `only_latest_for_role` option is set to true, find the latest active server for the given role if more than
      # one servers are found.
      #
      if only_latest_for_role
        server_hashes = server_hashes.sort_by { |_, server_hash| server_hash['lineage'] }.chunk do |_, server_hash|
          server_hash['lineage']
        end.map do |lineage, server_hashes|
          server_hashes.sort_by { |_, server_hash| server_hash['role'] || '' }.chunk do |_, server_hash|
            server_hash['role'] || ''
          end.map do |role, server_hashes|
            if role.empty?
              server_hashes
            else
              [server_hashes.max_by { |uuid, server_hash| server_hash["#{role}_since"] }]
            end
          end
        end

        server_hashes = Mash.from_hash(Hash[server_hashes.flatten(2)])
      end

      server_hashes
    end

    # Find database servers using tags. This will find all active database servers, or, if `lineage` is
    # given, it will find all database servers for that linage, or, if `role` is specified it will find
    # the database server(s) with that role.
    #
    # @param node [Chef::Node] the Chef node
    # @param lineage [String] the lineage of the database servers to search for
    # @param role [Symbol, String] the role of the database servers to search for; this should be `:master`
    #   or `:slave`
    #
    # @option options [Integer] :query_timeout (120) the seconds to timeout for the query operation
    #
    # @return [Mash] a hash with server UUIDs as keys and server information hashes as values
    #
    # @see .find_database_servers
    #
    def find_database_servers(node, lineage = nil, role = nil, options = {})
      Rightscale::RightscaleTag.find_database_servers(node, lineage, role, options)
    end

    # Groups the application servers hash returned by find_application_servers
    # method based on application names.
    #
    # @param servers [Mash{String, Mash}] the application servers hash
    #
    # @return [Mash] the pools hash with pool name as the key and the server hash
    #    as value
    #
    # @example
    #
    #   # Given the application servers hash as below
    #
    #   {
    #     '01-ABCDEF7890123' => {
    #       'applications' => {
    #         'www' => {
    #           'bind_ip_address' => '10.0.0.3',
    #           'bind_port' => 8080,
    #           'vhost_path' => '/',
    #         }
    #       },
    #       'public_ips' => ['203.0.113.3'],
    #       'private_ips' => ['10.0.0.3']
    #     },
    #     '01-EDFHG9876DFG' => {
    #       'applications' => {
    #         'api' => {
    #           'bind_ip_address' => '10.0.0.3',
    #           'bind_port' => 8080,
    #           'vhost_path' => '/',
    #         }
    #       },
    #       'public_ips' => ['8.0.13.3'],
    #       'private_ips' => ['10.0.0.3']
    #     }
    #   }
    #
    #   # This method returns
    #
    #   {
    #     'www' => {
    #       '01-ABCDEF7890123' => {
    #         'bind_ip_address' => '10.0.0.3',
    #         'bind_port' => 8080,
    #         'vhost_path' => '/',
    #       }
    #     }
    #     'api' => {
    #       {
    #         '01-EDFHG9876DFG' => {
    #           'bind_ip_address' => '10.0.0.3',
    #           'bind_port' => 8080,
    #           'vhost_path' => '/',
    #         }
    #       }
    #     ]
    #   }
    #
    def self.group_servers_by_application_name(servers)
      pools_hash = {}
      servers.each do |server_uuid, server_hash|
        server_hash['applications'].each do |app_name, app_hash|
          pools_hash[app_name] ||= {}
          pools_hash[app_name][server_uuid] = app_hash
        end
      end
      Mash.from_hash(pools_hash)
    end

    # Groups the application servers hash returned by find_application_servers
    # method based on application names.
    #
    # @param servers [Mash{String, Mash}] the application servers hash
    #
    # @return [Mash] the pools hash with pool name as the key and the server hash
    #    as value
    #
    # @see .group_servers_by_application_name
    #
    def group_servers_by_application_name(servers)
      Rightscale::RightscaleTag.group_servers_by_application_name(servers)
    end

    private

    # Adds required tags to the options for Chef::MachineTagHelper#tag_search that are needed for the various
    # `find_*_servers` methods. By default it will add `server:uuid`, any other requirements need to be passed
    # as additional arguments. This method can be called multiple times to add further tag requirements.
    #
    # @param options [Hash] the options hash to populate
    # @param tags [Array<String>] the required tags
    #
    def self.required_tags(options, *tags)
      require 'set'

      options[:required_tags] ||= Set['server:uuid']
      options[:required_tags] += tags
    end

    # Builds a hash of server information hashes to be returned by the `find_*_servers` methods. A callback
    # block can be passed to further populate each server information hash from each tag set.
    #
    # @param servers [Array<MachineTag::Set>] the array of tag sets returned by Chef::MachineTagHelper#tag_search
    # @param block [Proc(MachineTag::Set)] a block that does further processing on each tag set; it should
    #   return a hash that will be merged into the server information hash
    #
    # @return [Mash] the hash with server UUIDs as keys and server information hashes as values
    #
    def self.build_server_hash(servers, &block)
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

      Mash.from_hash(Hash[server_hashes])
    end
  end
end
