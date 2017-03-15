#
# Cookbook Name:: caws-rundeck
# Recipe:: tune_rundeck
# Description:: Tune rundeck per http://rundeck.org/docs/administration/tuning-rundeck.html

basedir = node['rundeck_server']['basedir']

open_file_limit = node['caws-rundeck']['tuning']['open-file-limit']

# http://rundeck.org/docs/administration/tuning-rundeck.html#file-descriptors
#
# In the tuning, the docs mention to raise limits in /etc/security/limits.conf
# This cookbook should be run along with the STIG cookbook ( https://supermarket.chef.io/cookbooks/stig )
# and the stig.limits attributes should be set there instead of here
execute 'raise file-max' do
  command "echo #{open_file_limit} > /proc/sys/fs/file-max"
  not_if "echo $(($(cat /proc/sys/fs/file-max) > #{open_file_limit})) | grep 0"
end

# Update the rundeck user's bashrc to point set up RDECK_BASE variable
# used for CLI tools
template "#{basedir}/.bashrc" do
  source 'bashrc.erb'
  variables('rdeck_base' => basedir)
end
