require "securerandom"
default['rhodecode']['admin']['user']           = 'admin'
default_unless['rhodecode']['admin']['passwd']  = SecureRandom.base64(128).gsub(/\W/, "")
default['rhodecode']['admin']['email']          = 'admin@localhost'
default['rhodecode']['repo']['path']            = '/srv/repos'
default['rhodecode']['system']['user']          = 'rhodecode'
default['rhodecode']['system']['group']         = 'rhodecode'
default['rhodecode']['db']['host']              = '127.0.0.1'
default['rhodecode']['db']['port']              = 5432
default['rhodecode']['db']['user']              = 'rhodecode'
default_unless['rhodecode']['db']['passwd']     = SecureRandom.base64(128).gsub(/\W/, "")
default['rhodecode']['db']['name']              = 'rhodecode'
default['rhodecode']['virtualenv']['path']      = '/var/www/rhodecode-venv'
default['rhodecode']['email']['to']             = 'admin@localhost'
default['rhodecode']['email']['errfrom']        = 'paste_error@localhost'
default['rhodecode']['email']['appfrom']        = 'rhodecode-noreply@localhost'
default['rhodecode']['smtp']['server']          = 'mail.server.com'
default['rhodecode']['smtp']['username']        =
default['rhodecode']['smtp']['password']        =
default['rhodecode']['smtp']['auth']            =
default['rhodecode']['smtp']['port']            = 25
default['rhodecode']['smtp']['use_tls']         = 'true'
default['rhodecode']['smtp']['use_ssl']         = 'false'
default['rhodecode']['host']                    = '0.0.0.0'
default['rhodecode']['port']                    = 5000
default['rhodecode']['force']['https']          = 'false'
default['rhodecode']['issue']['pattern']        = '(?:\s*#)(\d+)'
default['rhodecode']['issue']['server']         = 'https://myissueserver.com/{repo}/issue/{id}'
default['rhodecode']['issue']['prefix']         = '#'
default['rhodecode']['authError']               = 418
default['rhodecode']['index']['interval']       = 30
default_unless['rhodecode']['beaker']['key']    = SecureRandom.base64(128).gsub(/\W/, "")
default['postgresql']['db']['admin']            = 'postgres'
default['celery']['host']                       = 'localhost'
default['celery']['vhost']                      = '/rhodecode'
default['celery']['port']                       = 5672
default['celery']['user']                       = 'rhodecode'
default_unless['celery']['passwd']              = SecureRandom.base64(128).gsub(/\W/, "")
default['rabbitmq']['user']                     = 'rhodecode'
default['rabbitmq']['vhost']                    = '/rhodecode'
