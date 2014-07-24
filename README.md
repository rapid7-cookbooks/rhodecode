Rhodecode
=========

Chef RhodeCode Cookbook

Overview
========

This cookbook can be used to install rhodecode (with required packages) and setup
production.ini instances for use with multiple paster instances

Instructions
============

1. Set attributes
2. Deploy cookbook
3. Run the following commands to manually setup Rhodecode
```
/etc/init.d/rhodecode start
source /var/lib/rhodecode-venv/bin/activate
/var/lib/rhodecode-venv/bin/paster setup-rhodecode /var/lib/rhodecode/production1.ini
/var/lib/rhodecode-venv/bin/paster make-index
```

known issues
=========

* This cookbook will not configure or start rhodecode
* This has only been tested on Ubuntu 14.04 and Rhodecode 1.7.2 with 5
  paster instances
* The following passwords should be set from attributes or passwords
  will reset each chef run: celery:passwd, admin:passwd, beaker:key,
  db:passwd
* Special characters for database username, passwords, and database name are
  not supported. Paster currently munges special characters in the URI string
  by translating special characters into MIME encoded values which are passed
  as litteral strings. This results in authentication errors to the database.

todo
=========

* Detail all the attributes and their usage
* Use the new setup-rhodecode non-interactive config to replace production.ini.erb.
* Add support for multiple database backends.
* Add support for RHEL and other Linux based platforms.
* Add support for Windows servers.
* Fix MIME encoding in Paster.
