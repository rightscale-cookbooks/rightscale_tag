source "https://supermarket.chef.io"

metadata

cookbook 'marker', github: 'rightscale-cookbooks/marker', branch: 'chef-12-migration'
cookbook 'machine_tag', github: 'rightscale-cookbooks/machine_tag', branch: 'chef-12-migration'

group :integration do
  cookbook 'fake', path: './test/cookbooks/fake'
end
