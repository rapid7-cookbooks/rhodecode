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

database_user "#{node[:rodecode][:db_user]}" do
  connection root_db_connection_info
  password db_passwd
  provider Chef::Provider::Database::Postgresql
  action :create
end

postgresql_database "#{node[:rodecode][:db_name]}" do
  connection db_connection_info
  encoding 'utf8'
  owner 'db_user'
  action :create
end

rabbitmq_user "#{node[:rabbitmq][:mq_user]}" do
  password "#{node[:rhodecode][:mq_user][:mq_passwd]}"
  action :add
end

rabbitmq_vhost "#{node[:rabbitmq][:mq_vhost]}" do
    action :add
end

rabbitmq_user "#{node[:rabbitmq][:mq_user]}" do
  vhost "#{node[:rabbitmq][:mq_vhost]}"
  permissions "\".*\" \".*\" \".*\""
  action :set_permissions
end

python_pip 'rhodecode' do
  action :install
end

python_virtualenv "#{node[:rhodecode][:venv_path]}" do
  interpreter 'python2.7'
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


