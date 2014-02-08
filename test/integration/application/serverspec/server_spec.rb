# Test:: application server
require 'spec_helper'

#Get the hostname
host_name = `hostname -s`.chomp

app_tags = MachineTag::Set.new(JSON.parse(IO.read("/vagrant/cache_dir/machine_tag_cache/#{host_name}/tags.json")))

describe "Application (www) server tags" do
  it "should have a UUID of 02-BBCDEFG123457" do
    app_tags['server:uuid'].first.value.should match ('02-BBCDEFG123457')
  end
  it "should have a public IP of" do
    app_tags['server:public_ip_0'].first.value.should match ('33.33.33.10')
  end
  it "should have a private IP of" do
    app_tags['server:private_ip_0'].first.value.should match ('10.0.2.15')
  end
  it "should have 4 application specific entries" do
    app_tags['application'].length.should == 4
  end
  it "should be active" do
    app_tags['application:active_www'].first.value.should be_true
  end
  it "should have an IP of 10.0.0.1" do
    app_tags['application:bind_ip_address_www'].first.value.should match ('10.0.0.1')
  end
  it "should have an port of 8080" do
    app_tags['application:bind_port_www'].first.value.should match ('8080')
  end
  it "should have vhost path of www.example.com" do
    app_tags['application:vhost_path_www'].first.value.should match ('www.example.com')
  end
end


# We use find_application_servers helper to find all the application servers with name www, and we write results to
# file. Here we are loading the file so it can be parsed
app_server_tags = JSON.parse(IO.read("/tmp/found_app_servers.json"))

describe "Found www application servers" do
  it "should have a UUID of 02-BBCDEFG123457" do
    app_server_tags.has_key?('02-BBCDEFG123457').should be_true
  end
  it "should include a www server" do
    app_server_tags['02-BBCDEFG123457']['applications'].has_key?('www').should be_true
  end
  it "should include a bind IP address of 10.0.0.1" do
    app_server_tags['02-BBCDEFG123457']['applications']['www']['bind_ip_address'].should match ('10.0.0.1')
  end
  it "should include a bind port of 8080" do
    app_server_tags['02-BBCDEFG123457']['applications']['www']['bind_port'].should == 8080
  end
  it "should NOT include an API server" do
    app_server_tags['02-BBCDEFG123457']['applications'].has_key?('api').should be_false
  end
  it "should NOT include database server" do
    app_server_tags['02-BBCDEFG123457']['applications'].has_key?('master').should be_false
  end
end
