maintainer       "Ryan Hass"
maintainer_email "ryan underscore hass a t rapid7 d o t com"
license          "MIT"
description      "Installs/Configures RhodeCode"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.2"

depends          'rapid7_base', '~> 0.0.1'
depends          'nginx', '~> 0.101.6'
depends          "openssl"
depends          "mercurial"
depends          "git"
depends          "python"
depends          "postgresql"
depends          "database"
depends          "rabbitmq", "= 1.5.0"
depends          "cron"
