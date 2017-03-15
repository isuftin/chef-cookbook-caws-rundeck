#
# Cookbook Name:: caws-rundeck
# Recipe:: setup_jaas
# Description:: Writes JAAS template

rd_node = node['caws-rundeck']
skip if rd_node['jaas'].nil?

rd_db_config = rd_node['data_bag_config']
databag_name = rd_db_config['bag_name']
databag_passwords_item = rd_db_config['passwords_bag_item']
jaas_passwords_item = rd_db_config['jaas_passwords_attribute']

# Deep copy of the node object. I don't want to set secrets into the
# original object. I pass the copy of the node object to the template
# so the node info with secrets doesn't make it into the viewable
# node attributes
configs = node['caws-rundeck']['jaas'].to_a

if Chef::Config[:solo]
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
elsif search(databag_name, "id:#{databag_passwords_item}").any?
  passwords = data_bag_item(databag_name, databag_passwords_item)

  # Pull the credentials from the encrypted data bag
  credentials = passwords[jaas_passwords_item]

  configs.each do |config|
    skip unless config.key?('name')
    name = config['name']
    skip unless credentials.key?(name)
    credentials[name].each do |k, v|
      config['options'][k] = v
    end
  end
end

template 'jaas-template' do
  path     "#{node['rundeck_server']['confdir']}/jaas-module.conf"
  source   'jaas-template.conf.erb'
  variables(conf: configs)
  sensitive true
  user 'rundeck'
  group 'rundeck'
  notifies :restart, 'service[rundeckd]', :delayed
end
