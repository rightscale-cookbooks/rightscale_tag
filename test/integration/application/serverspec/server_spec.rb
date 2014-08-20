# Test:: application server
require 'spec_helper'
require 'socket'

describe 'Application LWRP' do
  let(:host_name) { Socket.gethostname.split('.').first }
  let(:app_tags) { MachineTag::Set.new(JSON.parse(IO.read("/vagrant/cache_dir/machine_tag_cache/#{host_name}/tags.json"))) }

  it 'should have 5 application specific entries' do
    app_tags['application'].length.should == 5
  end

  it 'should be active' do
    app_tags['application:active'].first.value.should be_truthy
    app_tags['application:active_www'].first.value.should be_truthy
  end

  it 'should have an IP of 10.0.0.1' do
    app_tags['application:bind_ip_address_www'].first.value.should eq('10.0.0.1')
  end

  it 'should have an port of 8080' do
    app_tags['application:bind_port_www'].first.value.should eq('8080')
  end

  it 'should have vhost path of www.example.com' do
    app_tags['application:vhost_path_www'].first.value.should eq('www.example.com')
  end
end

# We use find_application_servers helper to find all the application servers with name www, and we write results to
# file. Here we are loading the file so it can be parsed
describe 'Using find_application_servers helper method, the found www server should' do

  let(:app_server_tags) { JSON.parse(IO.read('/tmp/found_app_servers.json')) }

  it 'return a UUID of 02-BBCDEFG123457' do
    app_server_tags.has_key?('02-BBCDEFG123457').should be_truthy
  end

  it 'return a www server' do
    app_server_tags['02-BBCDEFG123457']['applications'].should have_key('www')
  end

  it 'return a bind IP address of 10.0.0.1' do
    app_server_tags['02-BBCDEFG123457']['applications']['www']['bind_ip_address'].should eq('10.0.0.1')
  end

  it 'return a bind port of 8080' do
    app_server_tags['02-BBCDEFG123457']['applications']['www']['bind_port'].should == 8080
  end
end
