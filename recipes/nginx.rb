include_recipe "nginx"

template '/etc/nginx/sites-available/rhodecode' do
  source 'nginx-site.erb'
  mode 0644
end

link '/etc/nginx/sites-enabled/rhodecode' do
  to '/etc/nginx/sites-available/rhodecode'
end
