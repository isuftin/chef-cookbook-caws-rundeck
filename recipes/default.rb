#
# Cookbook Name:: caws-rundeck
# Recipe:: default
#
# Description: This recipe primarilly serves to override a lot of what the rundeck-server
# cookbook provides in way of configuration. The problem with the base cookbook is that
# it requires a lot of the secrets configuration to reside in node attributes. This is
# very insecure and can be picked up using knife or via the Chef conole. With this cookbook,
# those secrets can reside in an encrypted data bag named rundeck-<environment> and the secrets
# are transferred to node configuration during converge time. Immediately after converge time,
# those secrets are then removed from the node definition so that they can't be picked up via
# knife or through the Chef console

# NOTES:
# - Make sure that the passwords going into the realm.properties file are MD5 hashed. At no point do we want plaintext passwords
#   sitting in the real.properties file
#   See: http://rundeck.org/docs/administration/authenticating-users.html#propertyfileloginmodule
#   The example used for this cookbook:
#     $ java -cp /var/lib/rundeck/bootstrap/jetty-all-7.6.0.v20120127.jar org.eclipse.jetty.util.security.Password jsmith mypass
#     $ java -cp /var/lib/rundeck/bootstrap/jetty-all-7.6.0.v20120127.jar org.eclipse.jetty.util.security.Password admin admin
#     $ java -cp /var/lib/rundeck/bootstrap/jetty-all-7.6.0.v20120127.jar org.eclipse.jetty.util.security.Password user user

rd_node = node['caws-rundeck']
grails_server_url = ''
# Pull the http/s addressing from attributes
if  !rd_node['http_protocol'].nil? && !rd_node['http_protocol'].empty? &&
    !rd_node['hostname'].nil? && !rd_node['hostname'].empty? &&
    !rd_node['port'].nil? && rd_node['port'].empty?
  # Get the grails URL from node attributes
  http_protocol = rd_node['http_protocol']
  hostname = rd_node['hostname']
  port = rd_node['port']
  grails_server_url = "#{http_protocol}://#{hostname}:#{port}"
else
  # Use the hostname for the grails URL
  grails_server_url = "http://#{node['fqdn']}:4440"
end

node.override['rundeck_server']['rundeck-config.properties']['grails.serverURL'] = grails_server_url
# Sets up node attributes that need to come from data bags
framework_server_password = ''
users = nil

# Check if the data bag for secrets exists in the first place
databag_name = node['caws-rundeck']['data_bag_config']['bag_name']
if Chef::Config[:solo]
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
elsif Chef::DataBag.list.key?(databag_name)
  databag_users_item = node['caws-rundeck']['data_bag_config']['users_bag_item']
  databag_passwords_item = node['caws-rundeck']['data_bag_config']['passwords_bag_item']
  framework_server_password_attribute = node['caws-rundeck']['data_bag_config']['framework_server_password_attribute']
  mysql_server_password_attribute = node['caws-rundeck']['data_bag_config']['mysql_server_password_attribute']
  rundeck_encryption_password_attribute = node['caws-rundeck']['data_bag_config']['encryption_password_attribute']

  # Check if the data bag item exists
  if search(databag_name, "id:#{databag_users_item}").any?
    users = data_bag_item(databag_name, databag_users_item)
    # Set the base cookbook real.properties to the data bag's hash minus the id field
    node.override['rundeck_server']['realm.properties'] = users.to_hash.reject { |k, _v| k == 'id' } unless users.nil?
  end

  if search(databag_name, "id:#{databag_passwords_item}").any?
    passwords = data_bag_item(databag_name, databag_passwords_item)
    framework_server_password = passwords[framework_server_password_attribute]
    mysql_server_password = passwords[mysql_server_password_attribute]
    rundeck_encryption_password = passwords[rundeck_encryption_password_attribute]

    if !framework_server_password.nil? && !framework_server_password.empty?
      node.override['rundeck_server']['rundeck-config.framework']['framework.server.password'] = framework_server_password
    end

    if !mysql_server_password.nil? && !mysql_server_password.empty?
      node.override['rundeck_server']['rundeck-config.properties']['dataSource.password'] = mysql_server_password
    end

    if !rundeck_encryption_password.nil? && !rundeck_encryption_password.empty?
      node.override['rundeck_server']['rundeck-config.properties']['rundeck.storage.converter.1.config.password'] = rundeck_encryption_password
      node.override['rundeck_server']['rundeck-config.properties']['rundeck.config.storage.converter.1.config.password'] = rundeck_encryption_password
    end
  end
end


include_recipe 'rundeck-server::install'
include_recipe 'rundeck-server::config'

# Define service
service 'rundeckd' do
  supports status: true, restart: true
  action [:enable, :start]
end


execute 'ensure api is up' do
  command "curl -s -k -f #{node['rundeck_server']['rundeck-config.framework']['framework.server.url']}"
  retries 10
  retry_delay 30
end

# Install rundeck gem for API communication
chef_gem 'rundeck' do
  version '>= 1.1.0'
  compile_time false
end

# Remove the credentials here so that they can't be attained via knife or through the console
unless framework_server_password.nil? || framework_server_password.empty?
  node.override['rundeck_server']['rundeck-config.framework']['framework.server.password'] = ''
end

unless mysql_server_password.nil? || mysql_server_password.empty?
  node.override['rundeck_server']['rundeck-config.properties']['dataSource.password'] = ''
end

unless rundeck_encryption_password.nil? || rundeck_encryption_password.empty?
  node.override['rundeck_server']['rundeck-config.properties']['rundeck.storage.converter.1.config.password'] = ''
  node.override['rundeck_server']['rundeck-config.properties']['rundeck.config.storage.converter.1.config.password'] = ''
end

node.override['rundeck_server']['realm.properties'] = {} unless users.nil?
