#
# Cookbook Name:: caws-rundeck
# Recipe:: libraries_install
# Description:: Installs Python, pip and virtualenv for general use

basedir = node['rundeck_server']['basedir']
jq_version = node['caws-rundeck']['installs']['jq']['version']

package 'python' do
  action %i[install upgrade]
end

package 'python-pip'

package 'python-virtualenv'

remote_file 'get_latest_jq' do
  path "#{basedir}/jq-#{jq_version}"
  source "https://github.com/stedolan/jq/releases/download/jq-#{jq_version}/jq-linux64"
  owner 'rundeck'
  mode 0o755
  action :create_if_missing
end

link '/usr/bin/jq' do
  to "#{basedir}/jq-#{jq_version}"
  action :create
end
