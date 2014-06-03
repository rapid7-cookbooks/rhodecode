rhodecode
=========

Chef RhodeCode Cookbook

known issues
=========

* Special characters for database username, passwords, and database name are
  not supported. Paster currently munges special characters in the URI string
  by translating special characters into MIME encoded values which are passed
  as litteral strings. This results in authentication errors to the database.

todo
=========

* Use the new setup-rhodecode non-interactive config to replace production.ini.erb.
* Add support for multiple database backends.
* Add support for RHEL and other Linux based platforms.
* Add support for Windows servers.
* Fix MIME encoding in Paster.
* Make nginx ssl keys optional/parameterized for possible cookbook publish
