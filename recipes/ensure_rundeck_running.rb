#
# Cookbook Name:: caws-rundeck
# Recipe:: ensure_rundeck_running
# Description:: Makes sure that Rundeck is running as expected

execute 'ensure api is up' do
  command "curl -s -k -f #{node['rundeck_server']['rundeck-config.framework']['framework.server.url']}"
  retries 10
  retry_delay 30
end
