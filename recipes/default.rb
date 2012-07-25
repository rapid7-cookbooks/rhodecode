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
include_recipe "openssl"
db_host = node['rhodecode']['db']['host']
db_port = node['rhodecode']['db']['port']
db_user = node['rhodecode']['db']['user']
db_name = node['rhodecode']['db']['name']
db_bag  = Chef::EncryptedDataBagItem.load("prod", "rhodecode_db_passwd")
mq_bag  = Chef::EncryptedDataBagItem.load("prod", "rhodecode_mq_passwd")

# This is dangerous as it will print the decrypted value to the screen and log
# it to the disk. However, it is useful for troubleshooting encrypted data bags.
# Do not uncomment this unless you fully understand the security implications.
#Chef::Log.debug("Decrypted password: " + db_bag["passwd"])

db_admin_connection_info = {
  :host     => db_host,
  :port     => db_port,
  :username => node['postgresql']['db']['admin'],
  :password => node['postgresql']['password']['postgres']
}
# This is dangerous as it will print the decrypted value to the screen and log
# it to the disk. However, it is useful for troubleshooting encrypted data bags.
# Do not uncomment this unless you fully understand the security implications.
#Chef::Log.debug("Admin connection info: #{db_admin_connection_info}")

Chef::Log.debug("Database User: " + db_user)
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
  action [ :create ]
end

user node['rhodecode']['system']['user'] do
  shell     '/usr/sbin/nologin'
  system    true
  supports  :manage_home => false
  action    :create
end

directory "/var/lib/rhodecode" do
  owner node['rhodecode']['system']['user']
  group node['rhodecode']['system']['group']
  mode "0750"
  action :create
end

directory "/var/log/rhodecode" do
  owner node['rhodecode']['system']['user']
  group node['rhodecode']['system']['group']
  mode "0750"
  action :create
end

# Create "/var/www" if it does not already exist.
directory "/var/www" do
  owner "www-data"
  group "www-data"
  action :create
end

# Create the virtualenv directory with the correct permissions.
directory node['python']['virtualenv']['path'] do
  owner node['rhodecode']['system']['user']
  group node['rhodecode']['system']['group']
  mode "0750"
  action :create
end

# Create the repository base directory.
directory node['rhodecode']['repo']['path'] do
  owner node['rhodecode']['system']['user']
  group node['rhodecode']['system']['group']
  mode  "0750"
  action :create
end

# Install the UUID gem to generate a random UUID while processing the deployment.ini.erb.
gem_package "uuid" do
  action :install
end

template "/var/lib/rhodecode/production.ini" do
  source "deployment.ini.erb"
  owner node['rhodecode']['system']['user']
  group node['rhodecode']['system']['group']
  mode 0640
  variables(
    { :db_data_bag => db_bag }
  )
end

python_pip 'rhodecode' do
  version '1.3.6'
  action :install
end

# Install psycopg2 for postgresql support in RhodeCode.
python_pip 'psycopg2' do
  action :install
end

# Install ldap headers for python-ldap.
package "libldap2-dev" do
  action :install
end

# Install SASL header for python-ldap.
package "libsasl2-dev" do
  action :install
end

# Install LDAP modules for LDAP authentication support. See setup docs for details.
# http://packages.python.org/RhodeCode/setup.html#setting-up-ldap-support
python_pip 'python-ldap' do
  action :install
end

# Specify --no-site-packages per RhodeCode documentation.
python_virtualenv node[:python][:virtualenv][:path] do
  owner node['rhodecode']['system']['user']
  group node['rhodecode']['system']['group']
  interpreter 'python2.7'
  options "--no-site-packages"
  action :create
end

template "/etc/cron.d/update-rhodecode-index" do
  source "update-rhodecode-index.erb"
end

# This is dangerous as it will print the decrypted value to the screen and log
# it to the disk. However, it is useful for troubleshooting encrypted data bags.
# Do not uncomment this unless you fully understand the security implications.
#Chef::Log.info("RabbitMQ Password: " + "'${mq_bag["passwd"])}'"
rabbitmq_user node[:rabbitmq][:user] do
  # Single quote password string to ensure special characters do not cause an
  # error when creating a new user. The user creation is done via shell_out,
  # making this essential.
#  password "'#{mq_bag["passwd"]}'"
  password node['celery']['passwd']
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

# *THIS WORKAROUND IS POTENTIALLY DESTRUCTIVE*
# Workaround a bug in non-interactive setup-rhodecode in which the script always
# prompts to destroy the current db. This has been resolved for the upcoming 1.4
# release.
# https://bitbucket.org/marcinkuzminski/rhodecode/issue/507
# **  BEGIN WORKAROUND **
execute "paster" do
  user node['rhodecode']['system']['user']
  group node['rhodecode']['system']['group']
  command "yes | paster setup-rhodecode /var/lib/rhodecode/production.ini -q --user=#{node['rhodecode']['admin']['user']} --password='#{node['rhodecode']['admin']['passwd']}' --email=#{node['rhodecode']['admin']['email']} --repos=#{node['rhodecode']['repo']['path']} && touch /var/lib/rhodecode/configured_by_chef"
  #  Do not re-run the setup-rhodecode PasteScript if it has successfully completed.
  creates "/var/lib/rhodecode/configured_by_chef"
  action :run
end
## ** END WORKAROUND **

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

template "/etc/init.d/rhodecode" do
  source "rhodecode.erb"
  mode 0755
end

template "/etc/init/celeryd.conf" do
  source "celeryd.conf.erb"
  mode 0644
end

template "/etc/logrotate.d/cerleryd" do
  source "celeryd-logrotate.erb"
  mode 0644
end

template "/etc/logrotate.d/rhodecode" do
  source "rhodecode-logrotate.erb"
  mode 0644
end

service "rhodecode" do
  supports :restart => true
  action [ :enable, :start ]
end

service "celeryd" do
  provider Chef::Provider::Service::Upstart
  action [ :enable, :start ]
end

