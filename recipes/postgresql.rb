
include_recipe 'postgresql::server'
include_recipe 'postgresql::ruby'
include_recipe 'database'

db_host   = node['rhodecode']['db']['host']
db_port   = node['rhodecode']['db']['port']
db_user   = node['rhodecode']['db']['user']
db_name   = node['rhodecode']['db']['name']
db_passwd = node['rhodecode']['db']['passwd']

db_admin_connection_info = {
  :host     => db_host,
  :port     => db_port,
  :username => node['postgresql']['db']['admin'],
  :password => node['postgresql']['password']['postgres']
}

Chef::Log.debug("Admin connection info: #{db_admin_connection_info}")
Chef::Log.debug("Database User: " + db_user)

postgresql_database db_name do
  connection db_admin_connection_info
  encoding 'utf8'
  action :create
end

# The database cookbook is written in a manner which requires the database to
# be created prior to creating a user. Moreover, the task fails when the option
# "database_name" is omitted.
postgresql_database_user db_user do
  connection db_admin_connection_info
  password db_passwd
  action [ :create ]
end
