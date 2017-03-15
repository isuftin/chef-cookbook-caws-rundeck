require 'chefspec'
require 'chefspec/berkshelf'
RSpec.configure do |config|
  config.platform = 'centos'
  config.version = '6.8'
  config.color = true
  config.file_cache_path = Chef::Config[:file_cache_path]
end

def mock_web_xml(role_name = 'user', timeout = 30)
  before(:each) do
    allow(::File).to receive(:new)
      .with('/var/lib/rundeck/exp/webapp/WEB-INF/web.xml')
      .and_return(<<XML)
<web-app>
  <security-role>
    <role-name>#{role_name}</role-name>
  </security-role>
  <session-config>
    <session-timeout>#{timeout}</session-timeout>
  </session-config>
</web-app>
XML
  end
end

at_exit { ChefSpec::Coverage.report! }
