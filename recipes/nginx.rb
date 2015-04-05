ssl_data_bag = Rhodecode::Helpers.load_data_bag(
  node['rhodecode']['nginx']['ssl_cert_data_bag'],
  node['rhodecode']['nginx']['ssl_cert_data_bag_item']
)

include_recipe 'nginx'

# Public key.
file "/etc/ssl/certs/#{node['rhodecode']['nginx']['host']}.pem" do
  mode 0644
  user 'root'
  group 'root'
  content "#{ssl_data_bag['cert']}"
  notifies :reload, 'service[nginx]', :delayed
end

# Private key.
file "/etc/ssl/private/#{node['rhodecode']['nginx']['host']}.key" do
  mode 0600
  user 'root'
  group 'root'
  content "#{ssl_data_bag['key']}"
  notifies :reload, 'service[nginx]', :delayed
end

template '/etc/nginx/sites-available/rhodecode' do
  source 'nginx-site.erb'
  mode 0644
  notifies :reload, 'service[nginx]'
  variables({
    host_name: node['rhodecode']['nginx']['host']
  })
end

link '/etc/nginx/sites-enabled/rhodecode' do
  to '/etc/nginx/sites-available/rhodecode'
end
