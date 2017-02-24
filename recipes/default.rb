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

# Pull the http/s addressing from attributes
if ! node['caws-rundeck']['http_protocol'].nil? && ! node['caws-rundeck']['http_protocol'].empty? &&
    ! node['caws-rundeck']['hostname'].nil? && ! node['caws-rundeck']['hostname'].empty? &&
    ! node['caws-rundeck']['port'].nil? && ! node['caws-rundeck']['port'].empty?
  # Get the grails URL from node attributes
  http_protocol = node['caws-rundeck']['http_protocol']
  hostname = node['caws-rundeck']['hostname']
  port = node['caws-rundeck']['port']
  node.override['rundeck_server']['rundeck-config.properties']['grails.serverURL'] = "#{http_protocol}://#{hostname}:#{port}"
else
  # Use the hostname for the grails URL
  node.override['rundeck_server']['rundeck-config.properties']['grails.serverURL'] = "http://#{node.fqdn}:4440"
end

# Sets up node attributes that need to come from data bags
framework_server_password = ""
mysql_password = ""
users = nil
databag_name = node['caws-rundeck']['data_bag_config']['bag_name']
databag_users_item = node['caws-rundeck']['data_bag_config']['users_bag_item']
databag_passwords_item = node['caws-rundeck']['data_bag_config']['passwords_bag_item']
framework_server_password_attribute = node['caws-rundeck']['data_bag_config']['framework_server_password_attribute']
mysql_server_password_attribute = node['caws-rundeck']['data_bag_config']['mysql_server_password_attribute']
rundeck_encryption_password_attribute = node['caws-rundeck']['data_bag_config']['encryption_password_attribute']

# Check if the data bag for secrets exists in the first place
if Chef::DataBag.list.key?(databag_name)

  # Check if the data bag item exists
  if search(databag_name, "id:#{databag_users_item}").any?
    users = data_bag_item(databag_name, databag_users_item)
    if ! users.nil?
      # Set the base cookbook real.properties to the data bag's hash minus the id field
      node.override['rundeck_server']['realm.properties'] = users.to_hash.reject {|k,v| k == "id"}
    end
  end

  if search(databag_name, "id:#{databag_passwords_item}").any?
    passwords = data_bag_item(databag_name, databag_passwords_item)
    framework_server_password = passwords[framework_server_password_attribute]
    mysql_server_password = passwords[mysql_server_password_attribute]
    rundeck_encryption_password = passwords[rundeck_encryption_password_attribute]

    if ! framework_server_password.nil? && ! framework_server_password.empty?
      node.override['rundeck_server']['rundeck-config.framework']['framework.server.password'] = framework_server_password
    end

    if ! mysql_server_password.nil? && ! mysql_server_password.empty?
      node.override['rundeck_server']['rundeck-config.properties']['dataSource.password'] = mysql_server_password
    end

    if ! rundeck_encryption_password.nil? && ! rundeck_encryption_password.empty?
      node.override['rundeck_server']['rundeck-config.properties']['rundeck.storage.converter.1.config.password'] = rundeck_encryption_password
      node.override['rundeck_server']['rundeck-config.properties']['rundeck.config.storage.converter.1.config.password'] = rundeck_encryption_password
    end
  end

end

include_recipe 'rundeck-server::default'

# Remove the credentials here so that they can't be attained via knife or through the console
if ! framework_server_password.nil? && ! framework_server_password.empty?
  node.override['rundeck_server']['rundeck-config.framework']['framework.server.password'] = ""
end

if ! mysql_server_password.nil? && ! mysql_server_password.empty?
  node.override['rundeck_server']['rundeck-config.properties']['dataSource.password'] = ""
end

if ! rundeck_encryption_password.nil? && ! rundeck_encryption_password.empty?
  node.override['rundeck_server']['rundeck-config.properties']['rundeck.storage.converter.1.config.password'] = ""
  node.override['rundeck_server']['rundeck-config.properties']['rundeck.config.storage.converter.1.config.password'] = ""
end

if ! users.nil?
  node.override['rundeck_server']['realm.properties'] = {}
end
