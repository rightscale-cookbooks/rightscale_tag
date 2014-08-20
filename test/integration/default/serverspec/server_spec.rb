# Test:: default server
require 'spec_helper'
require 'socket'

describe 'Default server tags' do
  let(:host_name) { Socket.gethostname.split('.').first }
  let(:default_tags) { MachineTag::Set.new(JSON.parse(IO.read("/vagrant/cache_dir/machine_tag_cache/#{host_name}/tags.json"))) }

  it 'should have a UUID of 01-ABCDEFG123456' do
    default_tags['server:uuid'].first.value.should eq('01-ABCDEFG123456')
  end

  it 'should have a public IP of 33.33.33.10' do
    default_tags['server:public_ip_0'].first.value.should eq('33.33.33.10')
  end

  it 'should have a private IP of 10.0.2.15' do
    default_tags['server:private_ip_0'].first.value.should eq('10.0.2.15')
  end

  it 'should have an Active monitoring state' do
    default_tags['rs_monitoring:state'].first.value.should eq('active')
  end

  it 'should have NOT have any Application tags' do
    default_tags['application'].should be_empty
  end

  it 'should have NOT have any Database tags' do
    default_tags['database'].should be_empty
  end

  it 'should have NOT have any Load Balancer tags' do
    default_tags['load_balancer'].should be_empty
  end
end
