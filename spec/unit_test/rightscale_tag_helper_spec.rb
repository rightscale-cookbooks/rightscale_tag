#
# Cookbook Name:: rightscale_tag
# Spec:: rightscale_tag_helper_spec
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

require 'spec_helper'

describe Rightscale::RightscaleTag do
  let(:node) do
    node = Chef::Node.new
    node.set['cloud']['provider'] = 'some_cloud'
    node
  end

  class Chef::MachineTagHelper; end

  class Fake; end

  let(:fake) do
    fake_obj = Fake.new
    fake_obj.extend(Rightscale::RightscaleTag)
    fake_obj
  end

  describe '.find_load_balancer_servers' do
    let(:load_balancer_1) do
      MachineTag::Set[
        'server:uuid=01-83PJQDO8911IT',
        'load_balancer:active=true',
        'load_balancer:active_www=true',
        'load_balancer:active_api=true',
        'server:public_ip_0=157.56.165.202',
        'server:public_ip_1=157.56.165.203',
        'server:private_ip_0=10.0.0.1',
      ]
    end

    let(:load_balancer_2) do
      MachineTag::Set[
        'server:uuid=01-83PJQDO8922IT',
        'load_balancer:active=true',
        'load_balancer:active_api=true',
        'server:public_ip_0=157.56.166.202',
        'server:public_ip_1=157.56.166.203',
      ]
    end

    context 'when no application name is specified' do
      let(:tags) do
        [load_balancer_1, load_balancer_2]
      end

      it 'returns tags from all load balancer servers' do
        Chef::MachineTagHelper.should_receive(:tag_search).with(
          node,
          'load_balancer:active=true',
          {:required_tags => Set['server:uuid']}
        ).and_return(tags)
        response = fake.find_load_balancer_servers(node)

        response.should include('01-83PJQDO8911IT')
        response['01-83PJQDO8911IT']['tags'].should eq(load_balancer_1)
        response['01-83PJQDO8911IT']['private_ips'].should eq(['10.0.0.1'])
        response['01-83PJQDO8911IT']['public_ips'].should eq(['157.56.165.202', '157.56.165.203'])
        response['01-83PJQDO8911IT']['application_names'].should eq(['www', 'api'])

        response.should include('01-83PJQDO8922IT')
        response['01-83PJQDO8922IT']['tags'].should eq(load_balancer_2)
        response['01-83PJQDO8922IT']['private_ips'].should be_empty
        response['01-83PJQDO8922IT']['public_ips'].should eq(['157.56.166.202', '157.56.166.203'])
        response['01-83PJQDO8922IT']['application_names'].should eq(['api'])
      end
    end

    context 'when an application name is specified and the application is available' do
      let(:tags) do
        [load_balancer_1, load_balancer_2]
      end

      it 'returns tags from the matching load balancer server' do
        Chef::MachineTagHelper.should_receive(:tag_search).with(
          node,
          'load_balancer:active_www=true',
          {:required_tags => Set['server:uuid']}
        ).and_return(tags)
        response = fake.find_load_balancer_servers(node, 'www')

        response.should include('01-83PJQDO8911IT')
        response['01-83PJQDO8911IT']['tags'].should eq(load_balancer_1)
        response['01-83PJQDO8911IT']['private_ips'].should eq(['10.0.0.1'])
        response['01-83PJQDO8911IT']['public_ips'].should eq(['157.56.165.202', '157.56.165.203'])
        response['01-83PJQDO8911IT']['application_names'].should eq(['www', 'api'])
      end
    end

    context 'when an application name is specified and the application is not available' do
      let(:tags) { [] }

      it 'returns an empty Mash' do
        Chef::MachineTagHelper.should_receive(:tag_search).with(
          node,
          'load_balancer:active_www=true',
          {:required_tags => Set['server:uuid']}
        ).and_return(tags)
        response = fake.find_load_balancer_servers(node, 'www')

        response.should be_an_instance_of(Mash)
        response.should be_empty
      end
    end
  end

  describe '.find_application_servers' do
    let(:application_server_1) do
      MachineTag::Set[
        'server:uuid=01-83PJQDO8911IT',
        'application:active=true',
        'application:active_www=true',
        'application:active_api=true',
        'application:bind_ip_address_www=157.56.165.202',
        'application:bind_ip_address_api=157.56.165.203',
        'application:bind_port_www=80',
        'application:bind_port_api=80',
        'application:vhost_path_www=/',
        'application:vhost_path_api=api.example.com',
        'server:public_ip_0=157.56.165.202',
        'server:public_ip_1=157.56.165.203',
        'server:private_ip_0=10.0.0.1',
      ]
    end

    let(:application_server_2) do
      MachineTag::Set[
        'server:uuid=01-83PJQDO8922IT',
        'application:active=true',
        'application:active_api=true',
        'application:bind_ip_address_api=157.56.166.202',
        'application:bind_port_api=443',
        'application:vhost_path_api=api.example.com',
        'server:public_ip_0=157.56.166.202',
        'server:public_ip_1=157.56.166.203',
      ]
    end

    let(:www_attributes_1) do
      Mash.from_hash(
        'bind_ip_address' => '157.56.165.202',
        'bind_port' => 80,
        'vhost_path' => '/'
      )
    end

    let(:api_attributes_1) do
      Mash.from_hash(
        'bind_ip_address' => '157.56.165.203',
        'bind_port' => 80,
        'vhost_path' => 'api.example.com'
      )
    end

    let(:api_attributes_2) do
      Mash.from_hash(
        'bind_ip_address' => '157.56.166.202',
        'bind_port' => 443,
        'vhost_path' => 'api.example.com'
      )
    end

    context 'when no application name is specified' do
      let(:tags) do
        [application_server_1, application_server_2]
      end

      it 'returns tags of all application servers' do
        Chef::MachineTagHelper.should_receive(:tag_search).with(
          node,
          'application:active=true',
          {:required_tags => Set['server:uuid']}
        ).and_return(tags)
        response = fake.find_application_servers(node)

        response.should include('01-83PJQDO8911IT')
        response['01-83PJQDO8911IT']['tags'].should eq(application_server_1)
        response['01-83PJQDO8911IT']['private_ips'].should eq(['10.0.0.1'])
        response['01-83PJQDO8911IT']['public_ips'].should eq(['157.56.165.202', '157.56.165.203'])
        response['01-83PJQDO8911IT']['applications'].should be_an_instance_of(Mash)
        response['01-83PJQDO8911IT']['applications']['www'].should eq(www_attributes_1)

        response.should include('01-83PJQDO8922IT')
        response['01-83PJQDO8922IT']['tags'].should eq(application_server_2)
        response['01-83PJQDO8922IT']['private_ips'].should eq([])
        response['01-83PJQDO8922IT']['public_ips'].should eq(['157.56.166.202', '157.56.166.203'])
        response['01-83PJQDO8922IT']['applications'].should be_an_instance_of(Mash)
        response['01-83PJQDO8922IT']['applications']['api'].should eq(api_attributes_2)
      end
    end

    context 'when an application name is specified and the application is available' do
      let(:tags) do
        [application_server_1, application_server_2]
      end

      it 'returns tags of matching application servers' do
        Chef::MachineTagHelper.should_receive(:tag_search).with(
          node,
          'application:active_www=true',
          {:required_tags => Set[
            'server:uuid',
            'application:bind_ip_address_www=*',
            'application:bind_port_www=*',
            'application:vhost_path_www=*'
          ]}
        ).and_return(tags)
        response = fake.find_application_servers(node, 'www')

        response.should include('01-83PJQDO8911IT')
        response['01-83PJQDO8911IT']['tags'].should eq(application_server_1)
        response['01-83PJQDO8911IT']['private_ips'].should eq(['10.0.0.1'])
        response['01-83PJQDO8911IT']['public_ips'].should eq(['157.56.165.202', '157.56.165.203'])
        response['01-83PJQDO8911IT']['applications'].should be_an_instance_of(Mash)
        response['01-83PJQDO8911IT']['applications']['www'].should eq(www_attributes_1)

        response.should include('01-83PJQDO8922IT')
        response['01-83PJQDO8922IT']['tags'].should eq(application_server_2)
        response['01-83PJQDO8922IT']['private_ips'].should eq([])
        response['01-83PJQDO8922IT']['public_ips'].should eq(['157.56.166.202', '157.56.166.203'])
        response['01-83PJQDO8922IT']['applications'].should be_an_instance_of(Mash)
        response['01-83PJQDO8922IT']['applications']['api'].should eq(api_attributes_2)
      end
    end

    context 'when an application name is specified and the application is not available' do
      let(:tags) { [] }

      it 'returns an empty Mash' do
        Chef::MachineTagHelper.should_receive(:tag_search).with(
          node,
          'application:active_www=true',
          {:required_tags => Set[
            'server:uuid',
            'application:bind_ip_address_www=*',
            'application:bind_port_www=*',
            'application:vhost_path_www=*'
          ]}
        ).and_return(tags)
        response = fake.find_application_servers(node, 'www')

        response.should be_an_instance_of(Mash)
        response.should be_empty
      end
    end
  end

  describe '.find_database_servers' do
    let(:database_master) do
      MachineTag::Set[
        'server:uuid=01-83PJQDO8911IT',
        'database:active=true',
        'database:master_active=1391803034',
        'database:lineage=example',
        'database:bind_ip_address=10.0.0.1',
        'database:bind_port=3306',
        'server:private_ip_0=10.0.0.1',
        'server:public_ip_0=157.56.165.202',
        'server:public_ip_1=157.56.165.203',
      ]
    end

    let(:database_slave) do
      MachineTag::Set[
        'server:uuid=01-83PJQDO8922IT',
        'database:active=true',
        'database:slave_active=1391803892',
        'database:lineage=example',
        'database:bind_ip_address=157.56.166.202',
        'database:bind_port=3306',
        'server:public_ip_0=157.56.166.202',
        'server:public_ip_1=157.56.166.203',
      ]
    end

    let(:database_master_2) do
      MachineTag::Set[
        'server:uuid=01-83PJQDO8933IT',
        'database:active=true',
        'database:master_active=1391802023',
        'database:lineage=example',
        'database:bind_ip_address=10.0.0.2',
        'database:bind_port=3306',
        'server:private_ip_0=10.0.0.2',
        'server:public_ip_0=157.56.165.204',
      ]
    end

    let(:database_slave_2) do
      MachineTag::Set[
        'server:uuid=01-83PJQDO8944IT',
        'database:active=true',
        'database:slave_active=1391803781',
        'database:lineage=example',
        'database:bind_ip_address=157.56.166.204',
        'database:bind_port=3306',
        'server:public_ip_0=157.56.166.204',
      ]
    end

    let(:database_standalone) do
      MachineTag::Set[
        'server:uuid=01-83PJQDO8955IT',
        'database:active=true',
        'database:lineage=example',
        'database:bind_ip_address=10.0.0.3',
        'database:bind_port=3306',
        'server:private_ip_0=10.0.0.3',
      ]
    end

    context 'when no database role or lineage is specified' do
      let(:tags) do
        [database_master, database_slave, database_standalone]
      end

      it 'returns tags of all database servers' do
        Chef::MachineTagHelper.should_receive(:tag_search).with(
          node,
          'database:active=true',
          {:required_tags => Set[
            'server:uuid',
            'database:lineage=*',
            'database:bind_ip_address=*',
            'database:bind_port=*',
          ]}
        ).and_return(tags)
        response = fake.find_database_servers(node)

        response.keys.should match_array(['01-83PJQDO8911IT', '01-83PJQDO8922IT', '01-83PJQDO8955IT'])

        response['01-83PJQDO8911IT']['tags'].should eq(database_master)
        response['01-83PJQDO8911IT']['private_ips'].should eq(['10.0.0.1'])
        response['01-83PJQDO8911IT']['public_ips'].should eq(['157.56.165.202', '157.56.165.203'])
        response['01-83PJQDO8911IT']['lineage'].should eq('example')
        response['01-83PJQDO8911IT']['role'].should eq('master')
        response['01-83PJQDO8911IT']['master_since'].should eq(Time.at(1391803034))
        response['01-83PJQDO8911IT'].should_not include('slave_since')
        response['01-83PJQDO8911IT']['bind_ip_address'].should eq('10.0.0.1')
        response['01-83PJQDO8911IT']['bind_port'].should eq(3306)

        response['01-83PJQDO8922IT']['tags'].should eq(database_slave)
        response['01-83PJQDO8922IT']['private_ips'].should eq([])
        response['01-83PJQDO8922IT']['public_ips'].should eq(['157.56.166.202', '157.56.166.203'])
        response['01-83PJQDO8922IT']['lineage'].should eq('example')
        response['01-83PJQDO8922IT']['role'].should eq('slave')
        response['01-83PJQDO8922IT'].should_not include('master_since')
        response['01-83PJQDO8922IT']['slave_since'].should eq(Time.at(1391803892))
        response['01-83PJQDO8922IT']['bind_ip_address'].should eq('157.56.166.202')
        response['01-83PJQDO8922IT']['bind_port'].should eq(3306)

        response['01-83PJQDO8955IT']['tags'].should eq(database_standalone)
        response['01-83PJQDO8955IT']['private_ips'].should eq(['10.0.0.3'])
        response['01-83PJQDO8955IT']['public_ips'].should eq([])
        response['01-83PJQDO8955IT']['lineage'].should eq('example')
        response['01-83PJQDO8955IT'].should_not include('role', 'master_since', 'slave_since')
        response['01-83PJQDO8955IT']['bind_ip_address'].should eq('10.0.0.3')
        response['01-83PJQDO8955IT']['bind_port'].should eq(3306)
      end

      context 'when only_latest_for_role is true' do
        let(:tags) do
          [database_master, database_slave, database_master_2, database_slave_2, database_standalone]
        end

        it 'returns only the latest masters and slaves and any standalones' do
          Chef::MachineTagHelper.should_receive(:tag_search).with(
            node,
            'database:active=true',
            {:required_tags => Set[
              'server:uuid',
              'database:lineage=*',
              'database:bind_ip_address=*',
              'database:bind_port=*',
            ]}
          ).and_return(tags)
          response = fake.find_database_servers(node, nil, nil, only_latest_for_role: true)

          response.keys.should match_array(['01-83PJQDO8911IT', '01-83PJQDO8922IT', '01-83PJQDO8955IT'])
          response['01-83PJQDO8911IT']['tags'].should eq(database_master)
          response['01-83PJQDO8922IT']['tags'].should eq(database_slave)
          response['01-83PJQDO8955IT']['tags'].should eq(database_standalone)
        end
      end
    end

    context 'when a server has both master and slave tags' do
      let(:database_master_with_slave_tag) do
        MachineTag::Set[*database_master, 'database:slave_active=1391802974']
      end

      let(:database_slave_with_master_tag) do
        MachineTag::Set[*database_slave, 'database:master_active=1391803832']
      end

      let(:tags) do
        [database_master_with_slave_tag, database_slave_with_master_tag]
      end

      it 'returns role of the latest tag' do
        Chef::MachineTagHelper.should_receive(:tag_search).with(
          node,
          'database:active=true',
          {:required_tags => Set[
            'server:uuid',
            'database:lineage=*',
            'database:bind_ip_address=*',
            'database:bind_port=*',
          ]}
        ).and_return(tags)
        response = fake.find_database_servers(node)

        response['01-83PJQDO8911IT']['tags'].should eq(database_master_with_slave_tag)
        response['01-83PJQDO8911IT']['role'].should eq('master')
        response['01-83PJQDO8911IT']['master_since'].should eq(Time.at(1391803034))
        response['01-83PJQDO8911IT']['slave_since'].should be_nil

        response['01-83PJQDO8922IT']['tags'].should eq(database_slave_with_master_tag)
        response['01-83PJQDO8922IT']['role'].should eq('slave')
        response['01-83PJQDO8922IT']['slave_since'].should eq(Time.at(1391803892))
        response['01-83PJQDO8922IT']['master_since'].should be_nil
      end
    end

    context 'when the database lineage is given and the role is not given' do
      let(:tags) do
        [database_master, database_slave, database_standalone]
      end

      it 'returns tags of all database servers' do
        Chef::MachineTagHelper.should_receive(:tag_search).with(
          node,
          'database:active=true',
          {:required_tags => Set[
            'server:uuid',
            'database:lineage=*',
            'database:bind_ip_address=*',
            'database:bind_port=*',
          ]}
        ).and_return(tags)
        response = fake.find_database_servers(node, 'example')

        response.keys.should match_array(['01-83PJQDO8911IT', '01-83PJQDO8922IT', '01-83PJQDO8955IT'])

        response['01-83PJQDO8911IT']['tags'].should eq(database_master)
        response['01-83PJQDO8911IT']['private_ips'].should eq(['10.0.0.1'])
        response['01-83PJQDO8911IT']['public_ips'].should eq(['157.56.165.202', '157.56.165.203'])
        response['01-83PJQDO8911IT']['lineage'].should eq('example')
        response['01-83PJQDO8911IT']['role'].should eq('master')
        response['01-83PJQDO8911IT'].should_not include('slave_since')
        response['01-83PJQDO8911IT']['master_since'].should eq(Time.at(1391803034))
        response['01-83PJQDO8911IT']['bind_ip_address'].should eq('10.0.0.1')
        response['01-83PJQDO8911IT']['bind_port'].should eq(3306)

        response['01-83PJQDO8922IT']['tags'].should eq(database_slave)
        response['01-83PJQDO8922IT']['private_ips'].should eq([])
        response['01-83PJQDO8922IT']['public_ips'].should eq(['157.56.166.202', '157.56.166.203'])
        response['01-83PJQDO8922IT']['lineage'].should eq('example')
        response['01-83PJQDO8922IT']['role'].should eq('slave')
        response['01-83PJQDO8922IT'].should_not include('master_since')
        response['01-83PJQDO8922IT']['slave_since'].should eq(Time.at(1391803892))
        response['01-83PJQDO8922IT']['bind_ip_address'].should eq('157.56.166.202')
        response['01-83PJQDO8922IT']['bind_port'].should eq(3306)

        response['01-83PJQDO8955IT']['tags'].should eq(database_standalone)
        response['01-83PJQDO8955IT']['private_ips'].should eq(['10.0.0.3'])
        response['01-83PJQDO8955IT']['public_ips'].should eq([])
        response['01-83PJQDO8955IT']['lineage'].should eq('example')
        response['01-83PJQDO8955IT'].should_not include('role', 'master_since', 'slave_since')
        response['01-83PJQDO8955IT']['bind_ip_address'].should eq('10.0.0.3')
        response['01-83PJQDO8955IT']['bind_port'].should eq(3306)
      end

      it 'returns an empty Mash when the lineage is not available' do
        Chef::MachineTagHelper.should_receive(:tag_search).with(
          node,
          'database:active=true',
          {:required_tags => Set[
            'server:uuid',
            'database:lineage=*',
            'database:bind_ip_address=*',
            'database:bind_port=*',
          ]}
        ).and_return([])
        response = fake.find_database_servers(node, 'undefined')

        response.should be_an_instance_of(Mash)
        response.should be_empty
      end

      context 'when only_latest_for_role is true' do
        let(:tags) do
          [database_master, database_slave, database_master_2, database_slave_2, database_standalone]
        end

        it 'returns only the latest masters and slaves and any standalones' do
          Chef::MachineTagHelper.should_receive(:tag_search).with(
            node,
            'database:active=true',
            {:required_tags => Set[
              'server:uuid',
              'database:lineage=*',
              'database:bind_ip_address=*',
              'database:bind_port=*',
            ]}
          ).and_return(tags)
          response = fake.find_database_servers(node, 'example', nil, only_latest_for_role: true)

          response.keys.should match_array(['01-83PJQDO8911IT', '01-83PJQDO8922IT', '01-83PJQDO8955IT'])
          response['01-83PJQDO8911IT']['tags'].should eq(database_master)
          response['01-83PJQDO8922IT']['tags'].should eq(database_slave)
          response['01-83PJQDO8955IT']['tags'].should eq(database_standalone)
        end
      end
    end

    context 'when the database role is given and the lineage is not given' do
      it 'returns tags of the master database server' do
        Chef::MachineTagHelper.should_receive(:tag_search).with(
          node,
          'database:master_active=*',
          {:required_tags => Set[
            'server:uuid',
            'database:active=true',
            'database:lineage=*',
            'database:bind_ip_address=*',
            'database:bind_port=*',
          ]}
        ).and_return([database_master])
        response = fake.find_database_servers(node, nil, 'master')

        response['01-83PJQDO8911IT']['tags'].should eq(database_master)
        response['01-83PJQDO8911IT']['private_ips'].should eq(['10.0.0.1'])
        response['01-83PJQDO8911IT']['public_ips'].should eq(['157.56.165.202', '157.56.165.203'])
        response['01-83PJQDO8911IT']['lineage'].should eq('example')
        response['01-83PJQDO8911IT']['role'].should eq('master')
        response['01-83PJQDO8911IT']['master_since'].should eq(Time.at(1391803034))
        response['01-83PJQDO8911IT']['bind_ip_address'].should eq('10.0.0.1')
        response['01-83PJQDO8911IT']['bind_port'].should eq(3306)
      end

      it 'returns tags of the slave database server' do
        Chef::MachineTagHelper.should_receive(:tag_search).with(
          node,
          'database:slave_active=*',
          {:required_tags => Set[
            'server:uuid',
            'database:active=true',
            'database:lineage=*',
            'database:bind_ip_address=*',
            'database:bind_port=*',
          ]}
        ).and_return([database_slave])
        response = fake.find_database_servers(node, nil, 'slave')

        response['01-83PJQDO8922IT']['tags'].should eq(database_slave)
        response['01-83PJQDO8922IT']['private_ips'].should eq([])
        response['01-83PJQDO8922IT']['public_ips'].should eq(['157.56.166.202', '157.56.166.203'])
        response['01-83PJQDO8922IT']['lineage'].should eq('example')
        response['01-83PJQDO8922IT']['role'].should eq('slave')
        response['01-83PJQDO8922IT']['slave_since'].should eq(Time.at(1391803892))
        response['01-83PJQDO8922IT']['bind_ip_address'].should eq('157.56.166.202')
        response['01-83PJQDO8922IT']['bind_port'].should eq(3306)
      end

      it 'returns an empty Mash when the role is not available' do
        Chef::MachineTagHelper.should_receive(:tag_search).with(
          node,
          'database:undefined_active=*',
          {:required_tags => Set[
            'server:uuid',
            'database:active=true',
            'database:lineage=*',
            'database:bind_ip_address=*',
            'database:bind_port=*',
          ]}
        ).and_return([])
        response = fake.find_database_servers(node, nil, 'undefined')

        response.should be_an_instance_of(Mash)
        response.should be_empty
      end

      context 'when only_latest_for_role is true for master role' do
        let(:tags) do
          [database_master, database_master_2]
        end

        it 'returns only the latest master' do
          Chef::MachineTagHelper.should_receive(:tag_search).with(
            node,
            'database:master_active=*',
            {:required_tags => Set[
              'server:uuid',
              'database:active=true',
              'database:lineage=*',
              'database:bind_ip_address=*',
              'database:bind_port=*',
            ]}
          ).and_return(tags)
          response = fake.find_database_servers(node, nil, 'master', only_latest_for_role: true)

          response.keys.should match_array(['01-83PJQDO8911IT'])
          response['01-83PJQDO8911IT']['tags'].should eq(database_master)
        end
      end
    end

    context 'when the database role and lineage is given' do
      it 'returns tags of the master database server matching example as lineage' do
        Chef::MachineTagHelper.should_receive(:tag_search).with(
          node,
          'database:master_active=*',
          {:required_tags => Set[
            'server:uuid',
            'database:active=true',
            'database:lineage=*',
            'database:bind_ip_address=*',
            'database:bind_port=*',
          ]}
        ).and_return([database_master])
        response = fake.find_database_servers(node, 'example', 'master')

        response['01-83PJQDO8911IT']['tags'].should eq(database_master)
        response['01-83PJQDO8911IT']['private_ips'].should eq(['10.0.0.1'])
        response['01-83PJQDO8911IT']['public_ips'].should eq(['157.56.165.202', '157.56.165.203'])
        response['01-83PJQDO8911IT']['lineage'].should eq('example')
        response['01-83PJQDO8911IT']['role'].should eq('master')
        response['01-83PJQDO8911IT']['master_since'].should eq(Time.at(1391803034))
        response['01-83PJQDO8911IT']['bind_ip_address'].should eq('10.0.0.1')
        response['01-83PJQDO8911IT']['bind_port'].should eq(3306)
      end

      it 'returns tags of the slave database server matching example as lineage' do
        Chef::MachineTagHelper.should_receive(:tag_search).with(
          node,
          'database:slave_active=*',
          {:required_tags => Set[
            'server:uuid',
            'database:active=true',
            'database:lineage=*',
            'database:bind_ip_address=*',
            'database:bind_port=*',
          ]}
        ).and_return([database_slave])
        response = fake.find_database_servers(node, 'example', 'slave')

        response['01-83PJQDO8922IT']['tags'].should eq(database_slave)
        response['01-83PJQDO8922IT']['private_ips'].should eq([])
        response['01-83PJQDO8922IT']['public_ips'].should eq(['157.56.166.202', '157.56.166.203'])
        response['01-83PJQDO8922IT']['lineage'].should eq('example')
        response['01-83PJQDO8922IT']['role'].should eq('slave')
        response['01-83PJQDO8922IT']['slave_since'].should eq(Time.at(1391803892))
        response['01-83PJQDO8922IT']['bind_ip_address'].should eq('157.56.166.202')
        response['01-83PJQDO8922IT']['bind_port'].should eq(3306)
      end

      it 'returns an empty Mash when the role is not available' do
        Chef::MachineTagHelper.should_receive(:tag_search).with(
          node,
          'database:undefined_active=*',
          {:required_tags => Set[
            'server:uuid',
            'database:active=true',
            'database:lineage=*',
            'database:bind_ip_address=*',
            'database:bind_port=*',
          ]}
        ).and_return([])
        response = fake.find_database_servers(node, 'example', 'undefined')

        response.should be_an_instance_of(Mash)
        response.should be_empty
      end

      it 'returns an empty Mash when the lineage is not available' do
        Chef::MachineTagHelper.should_receive(:tag_search).with(
          node,
          'database:master_active=*',
          {:required_tags => Set[
            'server:uuid',
            'database:active=true',
            'database:lineage=*',
            'database:bind_ip_address=*',
            'database:bind_port=*',
          ]}
        ).and_return([])
        response = fake.find_database_servers(node, 'undefined', 'master')

        response.should be_an_instance_of(Mash)
        response.should be_empty
      end

      it 'returns an empty Mash when both role and lineage are not available' do
        Chef::MachineTagHelper.should_receive(:tag_search).with(
          node,
          'database:undefined_active=*',
          {:required_tags => Set[
            'server:uuid',
            'database:active=true',
            'database:lineage=*',
            'database:bind_ip_address=*',
            'database:bind_port=*',
          ]}
        ).and_return([])
        response = fake.find_database_servers(node, 'undefined', 'undefined')

        response.should be_an_instance_of(Mash)
        response.should be_empty
      end

      context 'when only_latest_for_role is true for slave role' do
        let(:tags) do
          [database_slave, database_slave_2]
        end

        it 'returns only the latest slave' do
          Chef::MachineTagHelper.should_receive(:tag_search).with(
            node,
            'database:slave_active=*',
            {:required_tags => Set[
              'server:uuid',
              'database:active=true',
              'database:lineage=*',
              'database:bind_ip_address=*',
              'database:bind_port=*',
            ]}
          ).and_return(tags)
          response = fake.find_database_servers(node, 'example', 'slave', only_latest_for_role: true)

          response.keys.should match_array(['01-83PJQDO8922IT'])
          response['01-83PJQDO8922IT']['tags'].should eq(database_slave)
        end
      end
    end
  end

  describe '.group_servers_by_application_name' do
    let(:application_server_1) do
      MachineTag::Set[
        'server:uuid=01-83PJQDO8911IT',
        'application:active=true',
        'application:active_www=true',
        'application:active_api=true',
        'application:bind_ip_address_www=157.56.165.202',
        'application:bind_ip_address_api=157.56.165.203',
        'application:bind_port_www=80',
        'application:bind_port_api=80',
        'application:vhost_path_www=/',
        'application:vhost_path_api=api.example.com',
        'server:public_ip_0=157.56.165.202',
        'server:public_ip_1=157.56.165.203',
        'server:private_ip_0=10.0.0.1',
      ]
    end

    let(:application_server_2) do
      MachineTag::Set[
        'server:uuid=01-83PJQDO8922IT',
        'application:active=true',
        'application:active_api=true',
        'application:bind_ip_address_api=157.56.166.202',
        'application:bind_port_api=443',
        'application:vhost_path_api=api.example.com',
        'server:public_ip_0=157.56.166.202',
        'server:public_ip_1=157.56.166.203',
      ]
    end

    let(:www_attributes_1) do
      Mash.from_hash(
        'bind_ip_address' => '157.56.165.202',
        'bind_port' => 80,
        'vhost_path' => '/'
      )
    end

    let(:api_attributes_1) do
      Mash.from_hash(
        'bind_ip_address' => '157.56.165.203',
        'bind_port' => 80,
        'vhost_path' => 'api.example.com'
      )
    end

    let(:api_attributes_2) do
      Mash.from_hash(
        'bind_ip_address' => '157.56.166.202',
        'bind_port' => 443,
        'vhost_path' => 'api.example.com'
      )
    end

    context 'when application servers exist' do
      let(:tags) do
        [application_server_1, application_server_2]
      end

      it 'groups application servers by application name' do
        Chef::MachineTagHelper.should_receive(:tag_search).with(
          node, 'application:active=true',
          {:required_tags => Set['server:uuid']}
        ).and_return(tags)
        servers = fake.find_application_servers(node)
        response = Rightscale::RightscaleTag::group_servers_by_application_name(servers)

        response.should be_kind_of(Mash)

        response.should include('www')
        response['www'].should include('01-83PJQDO8911IT')
        response['www']['01-83PJQDO8911IT'].should eq(www_attributes_1)

        response.should include('api')
        response['api'].should include('01-83PJQDO8922IT')
        response['api']['01-83PJQDO8922IT'].should eq(api_attributes_2)

        response['api'].should include('01-83PJQDO8911IT')
        response['api']['01-83PJQDO8911IT'].should eq(api_attributes_1)
      end
    end
  end

  context 'when no application servers exists' do
    it 'should return an empty Mash' do
      response = Rightscale::RightscaleTag::group_servers_by_application_name(Mash.new)

      response.should be_kind_of(Mash)
      response.should be_empty
    end
  end
end
