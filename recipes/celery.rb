template '/etc/init/celeryd.conf' do
  source 'celeryd.conf.erb'
  mode 0644
end

template '/etc/logrotate.d/cerleryd' do
  source 'celeryd-logrotate.erb'
  mode 0644
end

service 'celeryd' do
  provider Chef::Provider::Service::Upstart
  action [ :enable, :start ]
end
