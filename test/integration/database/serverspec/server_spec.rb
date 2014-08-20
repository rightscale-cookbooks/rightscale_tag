# Test:: database server
require 'spec_helper'
require 'socket'
require 'time'

describe 'Database server tags' do
  let(:host_name) { Socket.gethostname.split('.').first }
  let(:db_tags) { MachineTag::Set.new(JSON.parse(IO.read("/vagrant/cache_dir/machine_tag_cache/#{host_name}/tags.json"))) }

  it 'should have 5 application specific entries' do
    db_tags['database'].length.should == 5
  end

  it 'should be active' do
    db_tags['database:active'].first.value.should be_truthy
  end

  it 'should have a lineage of production' do
    db_tags['database:lineage'].first.value.should eq('production')
  end

  # We want to test that the master_active timestamp is a reasonable value; arbitrarily within the last 24 hours
  let(:db_time) { Time.at(db_tags['database:master_active'].first.value.to_i) }

  it 'should have a master_active value that is valid (within the last 24 hours)' do
    (Time.now - db_time).should < 86_400
  end
end

# We use find_database_servers helper to find all the database severs, and we write results to a file.
# Here we are loading the file so it can be parsed
describe 'Found database application servers' do
  let(:db_server_tags) { JSON.parse(IO.read('/tmp/found_db_servers.json')) }

  it 'should have a UUID of 03-CBCDEFG123458' do
    db_server_tags.key?('03-CBCDEFG123458').should be_truthy
  end

  it 'should include a public IP address of 33.33.33.12' do
    db_server_tags['03-CBCDEFG123458']['public_ips'].first.should eq('33.33.33.12')
  end

  it 'should include a private IP address of 10.0.2.17' do
    db_server_tags['03-CBCDEFG123458']['private_ips'].first.should eq('10.0.2.17')
  end

  it 'should include a lineage of production' do
    db_server_tags['03-CBCDEFG123458']['lineage'].should eq('production')
  end

  it 'should have a role of master' do
    db_server_tags['03-CBCDEFG123458']['role'].should eq('master')
  end

  # We want to test that the master_active timestamp is a reasonable value; arbitrarily within the last 24 hours
  let(:time_from_tags) { Time.parse(db_server_tags['03-CBCDEFG123458']['master_since']).to_i}

  it 'should have a master_since timestamp that is valid (within the last 24 hours)' do
    (Time.now.utc.to_i - time_from_tags).should < 86_400
  end
end
