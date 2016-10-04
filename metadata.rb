name 'caws-rundeck'
maintainer 'Ivan Suftin'
maintainer_email 'isuftin@usgs.gov'
license 'all_rights'
description 'Installs/Configures caws-rundeck'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.0.15'

recommends 'stig', '>= 0.3.11'
depends 'rundeck-server', '>= 1.1.2'
depends 'iptables', '>= 2.2.0'
