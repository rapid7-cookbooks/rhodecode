#
# Cookbook Name:: rhodecode
# Recipe:: default
#
# Copyright 2012, Rapid7, LLC
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# 'Software'), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

include_recipe "postgresql::server"
include_recipe "database"
include_recipe "rabbitmq"
include_recipe "python::pip"
include_recipe "python::virtualenv"

db_host = node['rhodecode']['db']['host']
db_port = node['rhodecode']['db']['port']
db_user = node['rhodecode']['db']['user']
db_name = node['rhodecode']['db']['name']
db_bag  = Chef::EncryptedDataBagItem.load("prod", "rhodecode_db_passwd")
mq_bag  = Chef::EncryptedDataBagItem.load("prod", "rhodecode_mq_passwd")

#Chef::Log.info("Decrypted password: " + db_bag["passwd"])

db_admin_connection_info = {
  :host     => db_host,
  :port     => db_port,
  :username => node['postgresql']['db']['admin'],
  :password => node['postgresql']['password']['postgres']
}
Chef::Log.info("Admin connection info: #{db_admin_connection_info}")

Chef::Log.info("Database User: " + db_user)
postgresql_database db_name do
  connection db_admin_connection_info
  encoding 'utf8'
  action :create
end

# The database cookbook is written in a manner which requires the database to
# be created prior to creating a user. Morover, the task fails when the option
# "database_name" is omitted.
postgresql_database_user db_user do
  connection db_admin_connection_info
  password db_bag["passwd"]
  database_name db_name
  action [ :create, :grant ]
end

#Chef::Log.info("RabbitMQ Password: " + "'${mq_bag["passwd"])}'"
rabbitmq_user node[:rabbitmq][:user] do
  # Single quote password string to ensure special characters do not cause an
  # error when creating a new user. The user creation is done via shell_out,
  # making this essential.
  password "'#{mq_bag["passwd"]}'"
  action :add
end

rabbitmq_vhost node[:rabbitmq][:vhost] do
    action :add
end

rabbitmq_user node[:rabbitmq][:user] do
  vhost node[:rabbitmq][:vhost]
  permissions "\".*\" \".*\" \".*\""
  action :set_permissions
end

python_pip 'rhodecode' do
  action :install
end

python_virtualenv node[:python][:virtualenv][:path] do
  interpreter 'python2.7'
  options '--no-site-packages'
  action :create
end

# Force dependency on celery version 2.2.5 for compatibility with RhodeCode 1.3.6
python_pip 'celery' do
  version '2.2.5'
  action :install
end

# Force dependecy on kombu version 1.0.7 for comapatibility with celery 2.2.5
python_pip 'kombu' do
  version '1.0.7'
  action :install
end
