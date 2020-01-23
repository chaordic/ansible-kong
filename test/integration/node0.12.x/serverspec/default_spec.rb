require 'spec_helper'

kong_conf_dir = '/etc/kong/'
kong_nginx_working_dir = '/usr/local/kong'


describe package('kong-community-edition') do
  it { should be_installed }
end

describe file(kong_conf_dir) do
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by 'root' }
end

describe file(kong_nginx_working_dir) do
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by 'root' }
end

describe file("#{kong_conf_dir}/kong.conf") do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
end

describe file("/etc/logrotate.d/kong") do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
end

describe file("/usr/local/bin/kong") do
  it { should be_file }
  it { should be_mode 755 }
  it { should be_owned_by 'root' }
end

describe command("/usr/local/bin/kong version") do
  its(:stdout) { should match %r[(Kong version:\s)?0.*]i }
end

describe process("nginx") do
  it { should be_running }
  its(:args) { should match %r(-p /usr/local/kong -c nginx.conf) }
end

# verify serviceOne object is configured and serviceThree does not exist
describe command("curl -s http://localhost:8001/apis | jq '.data[].name'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match 'serviceOne' }
  its(:stdout) { should_not match 'serviceThree' }
end

# verify serviceTwo object is updated
describe command("curl -s http://localhost:8001/apis | jq '.data[] | {(.name): .uris }'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match 'serviceTwoUPDATED' }
end

# verify number of enabled plugins of serviceWithPlugins api object
describe command("curl -s http://localhost:8001/apis/serviceWithPlugins/plugins | jq '.total'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match '3' }
end

# verify enabled plugins of serviceWithPlugins api object
describe command("curl -s http://localhost:8001/apis/serviceWithPlugins/plugins | jq '.data[] | .name'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match 'acl' }
  its(:stdout) { should match 'oauth2' }
  its(:stdout) { should match 'basic-auth' }
  its(:stdout) { should_not match 'cors' }
end

# verify clientOne consumer object exists
describe command("curl -s http://localhost:8001/consumers | jq '.data[] | .username'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match 'clientOne' }
  its(:stdout) { should_not match 'clientTwo' }
end

# verify number of basic-auth credentials configured for clientOne consumer object
describe command("curl -s http://localhost:8001/consumers/clientOne/basic-auth | jq '.total'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match '2' }
end

# verify number of key-auth credentials configured for clientOne consumer object
describe command("curl -s http://localhost:8001/consumers/clientOne/key-auth | jq '.total'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match '2' }
end

# verify number of oauth2 credentials configured for clientOne consumer object
describe command("curl -s http://localhost:8001/consumers/clientOne/oauth2 | jq '.total'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match '2' }
end

# verify number of hmac-auth credentials configured for clientOne consumer object
describe command("curl -s http://localhost:8001/consumers/clientOne/hmac-auth | jq '.total'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match '2' }
end

# verify number of jwt credentials configured for clientOne consumer object
describe command("curl -s http://localhost:8001/consumers/clientOne/jwt | jq '.total'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match '2' }
end

# verify number of acl groups configured for clientOne consumer object
describe command("curl -s http://localhost:8001/consumers/clientOne/acls | jq '.total'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match '2' }
end
