# Initialize an index so the future executions from the crontab work properly.
execute "make-index" do
  user node['rhodecode']['system']['user']
  group node['rhodecode']['system']['group']
  command "paster make-index /var/lib/rhodecode/production.ini -f && touch /var/lib/rhodecode/.index-initialized-by-chef"
  creates "/var/lib/rhodecode/.index-initialized-by-chef"
  action :run
end
