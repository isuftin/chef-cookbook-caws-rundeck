#
# Cookbook Name:: caws-rundeck
# Recipe:: install_cli
# Description:: Sets up the Rundeck CLI provided in later versions of the Chef
# third party rundeck-server cookbook

db_config = node['caws-rundeck']['data_bag_config']
databag_name = node['caws-rundeck']['data_bag_config']['bag_name']
rd_token = ''

if Chef::Config[:solo]
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
elsif Chef::DataBag.list.key?(databag_name)
  rd_token_attribute = db_config['rd_token_attribute']
  databag_passwords_item = db_config['passwords_bag_item']
  if search(databag_name, "id:#{databag_passwords_item}").any?
    passwords = data_bag_item(databag_name, databag_passwords_item)
    rd_token = passwords[rd_token_attribute]
    if !rd_token.nil? && !rd_token.empty?
      node.override['rundeck_server']['cli']['config']['RD_TOKEN'] = rd_token
    end
  end
end

include_recipe 'rundeck-server::install_cli'

unless rd_token.nil? || rd_token.empty?
  node.override['rundeck_server']['cli']['config']['RD_TOKEN'] = ''
end
