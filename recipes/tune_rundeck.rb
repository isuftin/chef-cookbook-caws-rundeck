#
# Cookbook Name:: caws-rundeck
# Recipe:: tune_rundeck
# Description:: Tune rundeck per http://rundeck.org/docs/administration/tuning-rundeck.html

# Install wget in order to get latest JQ
package 'wget'

basedir = node['rundeck_server']['basedir']
jq_version = node['caws-rundeck']['installs']['jq']['version']
execute "get_latest_jq" do
  command "/usr/bin/wget -O #{basedir}/jq-#{jq_version} 'https://github.com/stedolan/jq/releases/download/jq-#{jq_version}/jq-linux64' "
  user "rundeck"
  not_if do ::File.exists?("#{basedir}/jq-#{jq_version}") end
end

file "#{basedir}/jq-#{jq_version}" do
  mode "0755"
end

link "/usr/bin/jq" do
  to "#{basedir}/jq-#{jq_version}"
end

open_file_limit = node['caws-rundeck']['tuning']['open-file-limit']


# http://rundeck.org/docs/administration/tuning-rundeck.html#file-descriptors
#
# In the tuning, the docs mention to raise limits in /etc/security/limits.conf
# This cookbook should be run along with the STIG cookbook ( https://supermarket.chef.io/cookbooks/stig )
# and the stig.limits attributes should be set there instead of here
execute "raise file-max" do
  command "echo #{open_file_limit} > /proc/sys/fs/file-max"
  not_if "echo $(($(cat /proc/sys/fs/file-max) > #{open_file_limit})) | grep 0"
end

# Update the rundeck user's bashrc to point set up RDECK_BASE variable
# used for CLI tools
template "#{basedir}/.bashrc" do
	source "bashrc.erb"
	variables({
		:rdeck_base => basedir
	})
end
