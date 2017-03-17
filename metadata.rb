name 'caws-rundeck'
maintainer 'Ivan Suftin'
maintainer_email 'isuftin@usgs.gov'
license 'all_rights'
description 'Installs/Configures caws-rundeck'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.0.3'

depends 'rundeck-server'
depends 'iptables', '>= 3.1.0'
source_url		 'https://github.com/USGS-CIDA/chef-cookbook-caws-rundeck'
issues_url		 'https://github.com/USGS-CIDA/chef-cookbook-caws-rundeck/issues'
