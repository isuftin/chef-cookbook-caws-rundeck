#
# Cookbook Name:: caws-rundeck
# Recipe:: iptables
# Description:: Sets up IPTables rules for Rundeck

node['caws-rundeck']['iptables']['rules'].map do |rule_name, rule_body|
  iptables_rule rule_name do
    lines [rule_body].flatten.join('\n')
  end
end
