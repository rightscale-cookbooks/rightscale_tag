# Test:: database server
require 'spec_helper'

# Get the hostname
host_name = `hostname -s`.chomp

db_tags = MachineTag::Set.new(JSON.parse(IO.read("/vagrant/cache_dir/machine_tag_cache/#{host_name}/tags.json")))

describe "Database server tags" do
  it "should have a UUID of 03-CBCDEFG123458" do
    db_tags['server:uuid'].first.value.should match ('03-CBCDEFG123458')
  end
  it "should have a public of 33.33.33.12" do
    db_tags['server:public_ip_0'].first.value.should match ('33.33.33.12')
  end
  it "should have a private IP of 10.0.2.17" do
    db_tags['server:private_ip_0'].first.value.should match ('10.0.2.17')
  end
  it "should have 3 application specific entries" do
    db_tags['database'].length.should == 3
  end
  it "should be active" do
    db_tags['database:active'].first.value.should be_true
  end
  it "should have a lineage of production" do
    db_tags['database:lineage'].first.value.should match ('production')
  end
  it "should have a master_active value of 1391473172" do
    db_tags['database:master_active'].first.value.should match ('1391473172')
  end
end

# We use find_database_servers helper to find all the database severs, and we write results to a file.
# Here we are loading the file so it can be parsed
db_server_tags = JSON.parse(IO.read("/tmp/found_db_servers.json"))

describe "Found database application servers" do
  it "should have a UUID of 03-CBCDEFG123458" do
    db_server_tags.has_key?('03-CBCDEFG123458').should be_true
  end
  it "should include a public IP address of 33.33.33.12" do
    db_server_tags['03-CBCDEFG123458']['public_ips'].first.should match ('33.33.33.12')
  end
  it "should include a private IP address of 10.0.2.17" do
    db_server_tags['03-CBCDEFG123458']['private_ips'].first.should match ('10.0.2.17')
  end
  it "should include a lineage of production" do
    db_server_tags['03-CBCDEFG123458']['lineage'].should match ('production')
  end
  it "should have a role of master" do
    db_server_tags['03-CBCDEFG123458']['role'].should match ('master')
  end
  it "should have been a master since 2014-02-04 00:19:32 +0000" do
    db_server_tags['03-CBCDEFG123458']['master_since'].should == '2014-02-04 00:19:32 +0000'
  end
end
