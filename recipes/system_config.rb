template '/etc/cron.d/update-rhodecode-index' do
  source 'update-rhodecode-index.erb'
end


# Build a string of numbers for our instance count
instances = ""
for num in 1..node['rhodecode']['instance']['count']
  instances << "#{num} "
end

template '/etc/init.d/rhodecode' do
  source 'rhodecode.erb'
  mode 0755
  variables({
    :instance_count => instances
  })
end

template '/etc/logrotate.d/rhodecode' do
  source 'rhodecode-logrotate.erb'
  mode 0644
end
