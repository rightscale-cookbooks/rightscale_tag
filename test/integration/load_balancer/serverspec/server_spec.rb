# Test:: load_balancer server
require 'spec_helper'

# Get the hostname
host_name = `hostname -s`.chomp

lb_tags = MachineTag::Set.new(JSON.parse(IO.read("/vagrant/cache_dir/machine_tag_cache/#{host_name}/tags.json")))

describe "Load balancer server tags" do
  it "should have a UUID of 04-DBCDEFG123459" do
    lb_tags['server:uuid'].first.value.should match ('04-DBCDEFG123459')
  end
  it "should have a public IP of 33.33.33.11" do
    lb_tags['server:public_ip_0'].first.value.should match ('33.33.33.11')
  end
  it "should have a private IP of 10.0.2.16" do
    lb_tags['server:private_ip_0'].first.value.should match ('10.0.2.16')
  end
  it "should have 1 application specific entry" do
    lb_tags['load_balancer'].length.should == 1
  end
  it "should have an active API" do
    lb_tags['load_balancer:active_api'].should be_true
  end
end

# We use find_load_balancer_servers helper to find all the load balancers with name api, and we write results to a file.
# Here we are loading the file so it can be parsed
lb_server_tags = JSON.parse(IO.read("/tmp/found_lb_servers.json"))

describe "Found load balancer server" do
  it "should have a UUID of 04-DBCDEFG123459" do
    lb_server_tags.has_key?('04-DBCDEFG123459').should be_true
  end
  it "should have a public IP address of 33.33.33.11" do
    lb_server_tags['04-DBCDEFG123459']['public_ips'].first.should match ('33.33.33.11')
  end
  it "should have a private IP address of 10.0.2.16" do
    lb_server_tags['04-DBCDEFG123459']['private_ips'].first.should match ('10.0.2.16')
  end
  it "should have an application name of api" do
    lb_server_tags['04-DBCDEFG123459']['application_names'].first.should match ('api')
  end
end
