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
          node, 'load_balancer:', {:required_tags => Set['server:uuid']}
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
          node, 'load_balancer:active_www=true', {:required_tags => Set['server:uuid']}
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
          node, 'load_balancer:active_www=true', {:required_tags => Set['server:uuid']}
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
          node, 'application:',
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
          node, 'application:active_www=true',
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
          node, 'application:active_www=true',
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
end
