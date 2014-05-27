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

# Install 
python_pip 'mercurial' do
  virtualenv node['rhodecode']['virtualenv']['path']
  user node['rhodecode']['system']['user']
  group node['rhodecode']['system']['group']
  action [:install, :upgrade]
end

# Install psycopg2 for postgresql support in RhodeCode.
python_pip 'psycopg2' do
  virtualenv node['rhodecode']['virtualenv']['path']
  user node['rhodecode']['system']['user']
  group node['rhodecode']['system']['group']
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
  user node['rhodecode']['system']['user']
  group node['rhodecode']['system']['group']
  action :install
end

python_pip 'celery' do
  virtualenv node['rhodecode']['virtualenv']['path']
  user node['rhodecode']['system']['user']
  group node['rhodecode']['system']['group']
  action :install
end

python_pip 'kombu' do
  virtualenv node['rhodecode']['virtualenv']['path']
  user node['rhodecode']['system']['user']
  group node['rhodecode']['system']['group']
  action :install
end

# The version of dulwich which RhodeCode (=< 1.7.2) depends on is no longer
# available in pypi. To work around this issue, we need to download the
# required version and install it manually into the virtual environment.
remote_file ::File.join(Chef::Config[:file_cache_path], 'dulwich-0.8.7.tar.gz') do
  source 'https://github.com/jelmer/dulwich/archive/dulwich-0.8.7.tar.gz'
  checksum '4e85698cb04fd69e56004e952a2f9a1f5756cf65e06174dbd55635d02cdaab66'
end

execute 'install_old_dulwich' do
  command "#{::File.join(node['rhodecode']['virtualenv']['path'], 'bin', 'pip')} install \
           #{::File.join(Chef::Config[:file_cache_path], 'dulwich-0.8.7.tar.gz')}"
  not_if "#{::File.join(node['rhodecode']['virtualenv']['path'], 'bin', 'pip')} \
          freeze | grep -q dulwich==0.8.7"
end

python_pip 'rhodecode' do
  version '1.7.2'
  virtualenv node['rhodecode']['virtualenv']['path']
  user node['rhodecode']['system']['user']
  group node['rhodecode']['system']['group']
  action :install
end

