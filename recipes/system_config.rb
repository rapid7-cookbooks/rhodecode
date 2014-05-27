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
