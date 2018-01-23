#
# Cookbook Name:: caws-rundeck
# Recipe:: setup_ssl
# Description:: Set up rundeck ssl

# Get passwords (if any) from the rundeck data bag
rd_node = node['caws-rundeck']
db_config = rd_node['data_bag_config']
databag_name = db_config['ssl_bag_name']
databag_item = db_config['ssl_passwords_bag_item']
ssl_password_attribute = db_config['ssl_password_attribute']
ssl_key_password_attribute = db_config['ssl_key_password_attribute']

passwords = data_bag_item(databag_name, databag_item)
ssl_password = passwords[ssl_password_attribute]
ssl_src_key_password = passwords[ssl_key_password_attribute]

# Get the remote cert file location if one is defined
ssl_config = rd_node['ssl_config']
remote_cert_file = ssl_config['ssl_cert_file']
remote_key_file = ssl_config['ssl_key_file']

[
  "SSL Source data bag: #{databag_name}/#{databag_item}",
  "SSL password attribute: #{ssl_password_attribute}",
  "SSL key password attribute: #{ssl_key_password_attribute}",
  "SSL cert file location: #{remote_cert_file}",
  "SSL key file location: #{remote_key_file}"
].each do |l|
  log l do
    level :debug
  end
end

# Set up some local string constants
local_pk12 = '/root/keystore.p12'
local_cert_file = '/root/ssl.crt'
local_key_file = '/root/ssl.key'
ssl_config_location = '/etc/rundeck/ssl'
keystore_location = "#{ssl_config_location}/keystore"
truststore_location = "#{ssl_config_location}/truststore"

# Default the host to be the machine's hostname or take it from the attributes, if available
host = node['fqdn']
if !rd_node['hostname'].nil? && !rd_node['hostname'].empty?
  host = rd_node['hostname']
end
rundeck = 'rundeck'

if !remote_cert_file.nil? && !remote_cert_file.empty?
  # A certificate file was provided. Import that into the keystore and use it. Only do so if it
  # differs from what is already available
  remote_file local_cert_file do
    source "file://#{remote_cert_file}"
    action :create
    notifies :create_if_missing, "remote_file[#{local_key_file}]", :immediately
    notifies :delete, 'file[delete_previous_cert]', :immediately
    notifies :delete, 'file[delete_previous_truststore]', :immediately
    notifies :run, 'execute[convert_cert]', :immediately
    notifies :run, 'execute[import_cert]', :immediately
    notifies :delete, 'file[delete_local_keyfile]', :immediately
    notifies :restart, 'service[rundeckd]', :immediately
    sensitive true
  end

  remote_file local_key_file do
    source "file://#{remote_key_file}"
    action :nothing
    sensitive true
  end

  # First, delete the previous certificate or the keytool command doesn't work properly
  file 'delete_previous_cert' do
    path keystore_location
    action :nothing
  end

  file 'delete_previous_truststore' do
    path truststore_location
    action :nothing
  end

  # Construct pkcs12 command with optional source key password if provided need
  pkcs12_command = "/usr/bin/openssl pkcs12 -export -name #{rundeck} -in #{local_cert_file} -inkey #{local_key_file} -out #{local_pk12} -password pass:#{ssl_password}"
  if !ssl_src_key_password.nil? && !ssl_src_key_password.empty?
    pkcs12_command << " -passin pass:#{ssl_src_key_password}"
  end

  # Convert the certificate
  execute 'convert_cert' do
    command pkcs12_command
    sensitive true
    action :nothing
  end

  # Import the certificate
  execute 'import_cert' do
    command "/usr/bin/keytool -importkeystore -destkeystore #{keystore_location} -srckeystore #{local_pk12} -srcstoretype pkcs12 -alias rundeck -srcstorepass #{ssl_password} -deststorepass #{ssl_password} -noprompt"
    sensitive true
    action :nothing
  end

  # Delete sensitive key file from local system
  file 'delete_local_keyfile' do
    path local_key_file
    action :nothing
  end

else
  # A certificate was not provided so create one
  # TODO- Create an idempotent way to repeat this if any of the values happen to change
  org_unit = ssl_config['org_unit']
  org = ssl_config['org']
  locality = ssl_config['locality']
  state = ssl_config['state']
  country = ssl_config['country']
  execute 'Create keystore' do
    command "/usr/bin/keytool -genkey -noprompt -keystore #{keystore_location}  -alias 'rundeck' -keyalg RSA -keypass #{ssl_password} -storepass #{ssl_password} -dname 'CN=#{host}, OU=#{org_unit}, O=#{org}, L=#{locality}, S=#{state}, C=#{country}'"
    notifies :restart, 'service[rundeckd]', :immediately
    sensitive true
    not_if { ::File.exist?(keystore_location) }
  end
end

remote_file 'Copy keystore to truststore' do
  path truststore_location
  source "file://#{keystore_location}"
end

file keystore_location do
  user rundeck
  owner rundeck
end

file truststore_location do
  user rundeck
  owner rundeck
end

template "#{ssl_config_location}/ssl.properties" do
  source 'ssl.properties.erb'
  variables(
    'keystore_location' => keystore_location,
    'truststore_location' => truststore_location,
    'pass' => ssl_password
  )
  user rundeck
  owner rundeck
  mode 0o644
  sensitive true
  notifies :restart, 'service[rundeckd]', :immediately
end
