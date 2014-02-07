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

      it 'should return tags from all load balancer servers' do
        Chef::MachineTagHelper.should_receive(:tag_search).with(
          node, 'load_balancer:', {:required_tags => Set['server:uuid']}
        ).and_return(tags)
        response = fake.find_load_balancer_servers(node)

        # TODO: Remove me
        print response.pretty_inspect
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
  end
end
