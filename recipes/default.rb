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

db_passwd                   = encrypted_data_bag_item('prod', 'rhodecode_db_passwd')
root_db_passwd              = encrypted_data_bag_item('prod', 'rhodecode_db_root_passwd')
root_db_connection_info     = {:host => ['db_server'], :port => ['db_port'], :username => ['db_user'], :password => node['postgresql']['passwd']}
db_connection_info          = {:host => ['db_server'], :port => ['db_port'], :username => ['db_user'], :password => node['postgresql']['passwd']}

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

# randomly generate rabbitmq password
node.set_unless[:rhodecode][:mq_user][:mq_passwd] = secure_password
node.save unless Chef::Config[:solo]

include_recipe 'python::pip'
include_recipe 'python::virtualenv'

database_user '['db_user']' do
  connection root_db_connection_info
  password db_passwd
  provider Chef::Provider::Database::Postgresql
  action :create
end

postgresql_database '['db_name']' do
  connection db_connection_info
  encoding 'utf8'
  owner 'db_user'
  action :create
end

rabbitmq_user '['mq_user']' do
  password "#{node[:rhodecode][:mq_user][:mq_passwd]}"
  action :add
end

rabbitmq_vhost "#{node[:rabbitmq][:mq_vhost]}" do
    action :add
end

python_pip 'rhodecode' do
  action :install
end

python_virtualenv '/var/www/rhodecode-venv' do
  interpreter 'python2.7'
  action :create
end

python_pip 'celery' do
  action :install
end

python_pip 'kombu' do
  action :install
end


