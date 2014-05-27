# Install the UUID gem to generate a random UUID while processing the deployment.ini.erb.
chef_gem 'uuid' do
  action :install
end

template '/var/lib/rhodecode/production.ini' do
  source 'deployment.ini.erb'
  owner node['rhodecode']['system']['user']
  group node['rhodecode']['system']['group']
  mode 0640
  backup 1
  action :create_if_missing
end

template '/etc/cron.d/update-rhodecode-index' do
  source 'update-rhodecode-index.erb'
end

template '/etc/init.d/rhodecode' do
  source 'rhodecode.erb'
  mode 0755
end

template '/etc/logrotate.d/rhodecode' do
  source 'rhodecode-logrotate.erb'
  mode 0644
end
