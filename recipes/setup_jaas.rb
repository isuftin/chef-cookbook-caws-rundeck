#
# Cookbook Name:: caws-rundeck
# Recipe:: setup_jaas
# Description:: Writes JAAS template

if ! node['caws-rundeck']['jaas'].nil?
  databag_name = node['caws-rundeck']['data_bag_config']['bag_name']
  databag_passwords_item = node['caws-rundeck']['data_bag_config']['passwords_bag_item']
  jaas_passwords_item = node['caws-rundeck']['data_bag_config']['jaas_passwords_attribute']
  if search(databag_name, "id:#{databag_passwords_item}").any?
    passwords = data_bag_item(databag_name, databag_passwords_item)
  end

  # Pull the credentials from the encrypted data bag
  credentials = passwords[jaas_passwords_item]

  # Deep copy of the node object. I don't want to set secrets into the
  # original object. I pass the copy of the node object to the template
  # so the node info with secrets doesn't make it into the viewable
  # node attributes
  configs = node['caws-rundeck']['jaas'].to_a

  configs.each do |config|
    if config.key?('name')
      name = config['name']
      if credentials.key?(name)
        credentials[name].each do |k,v|
          config['options'][k] = v
        end
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
end
