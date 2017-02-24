#
# Cookbook Name:: caws-rundeck
# Recipe:: python_install
# Description:: Installs Python, pip and virtualenv for general use

include_recipe 'yum-epel'

package 'python' do
  action [ :install, :upgrade ]
end

package 'python-pip'

package 'python-virtualenv'
