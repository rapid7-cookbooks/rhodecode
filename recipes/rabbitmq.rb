include_recipe "rabbitmq"

rabbitmq_user "guest" do
  action :delete
end

rabbitmq_user node['rabbitmq']['user'] do
  password node['celery']['passwd']
  action :add
end

rabbitmq_vhost node['rabbitmq']['vhost'] do
    action :add
end

rabbitmq_user node['rabbitmq']['user'] do
  vhost node['rabbitmq']['vhost']
  permissions '.* .* .*'
  action :set_permissions
end

