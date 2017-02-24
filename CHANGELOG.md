#### Changelog

0.1.0
------
- [isuftin@usgs.gov] Move to latest version of the IPTables cookbook which incorporates using attributes instead of templates
- [isuftin@usgs.gov] Included the yum-epel cookbook as a dependency. Added a recipe to allow installation of python, pip and virtualenv

0.0.15
------
- [isuftin@usgs.gov] Install latest version of JQ

0.0.14
------
- [isuftin@usgs.gov] Set the RDECK_BASE environment variable for the rundeck user in order to allow for rd-* CLI commands to work properly
- [isuftin@usgs.gov] Added dependency to Yum cookbook in order to add EPEL RHEL repo so JQ can be installed by default

0.0.13
------
- [isuftin@usgs.gov] Add ability to use Jasypt encryption with pass coming from data bag
