include_recipe 'python'

user node['rhodecode']['system']['user'] do
  shell     '/usr/sbin/nologin'
  system    true
  supports  :manage_home => false
  action    :create
end

# Create the virtualenv directory with the correct permissions.
directory node['rhodecode']['virtualenv']['path'] do
  owner node['rhodecode']['system']['user']
  group node['rhodecode']['system']['group']
  recursive true
  mode 0750
  action :create
end

# Specify --no-site-packages per RhodeCode documentation.
python_virtualenv node['rhodecode']['virtualenv']['path'] do
  owner node['rhodecode']['system']['user']
  group node['rhodecode']['system']['group']
  interpreter 'python2.7'
  options '--no-site-packages'
  action :create
end

python_pip 'rhodecode' do
  version '1.7.1'
  virtualenv node['rhodecode']['virtualenv']['path']
  options '--allow-external'
  action :install
end

# Install psycopg2 for postgresql support in RhodeCode.
python_pip 'psycopg2' do
  virtualenv node['rhodecode']['virtualenv']['path']
  action :install
end

# Install ldap headers for python-ldap.
package 'libldap2-dev' do
  action :install
end

# Install SASL header for python-ldap.
package 'libsasl2-dev' do
  action :install
end

# Install LDAP modules for LDAP authentication support. See setup docs for details.
# http://packages.python.org/RhodeCode/setup.html#setting-up-ldap-support
python_pip 'python-ldap' do
  virtualenv node['rhodecode']['virtualenv']['path']
  action :install
end

python_pip 'celery' do
  virtualenv node['rhodecode']['virtualenv']['path']
  action :install
end

python_pip 'kombu' do
  virtualenv node['rhodecode']['virtualenv']['path']
  action :install
end

python_pip 'mercurial' do
  virtualenv node['rhodecode']['virtualenv']['path']
  action :install
end
