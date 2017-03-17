# See https://github.com/Webtrends/rundeck for attributes

# Override the default address the cookbook sets which is the system's FQDN using HTTP
default['caws-rundeck']['http_protocol'] = ""
default['caws-rundeck']['hostname'] = ""
default['caws-rundeck']['port'] = ""

# IPTables rules
default['caws-rundeck']['iptables']['rules']['http'] = '-A FWR -p tcp -m tcp --dport 4440 -j ACCEPT'
default['caws-rundeck']['iptables']['rules']['https'] = '-A FWR -p tcp -m tcp --dport 4443 -j ACCEPT'

# Tuning rundeck. See http://rundeck.org/docs/administration/tuning-rundeck.html
default['caws-rundeck']['tuning']['open-file-limit'] = 65535

# Which version of JQ to install
default['caws-rundeck']['installs']['jq']['version'] = "1.5"

# The following configuration is used when you include the caws-rundeck::setup_ssl recipe in your
# runlist

# The location pointing to where the SSL cert and key files are on the server.
# Example: /root/ssl.crt and /root/ssl.key
default['caws-rundeck']['ssl_config']['ssl_cert_file'] = ""
default['caws-rundeck']['ssl_config']['ssl_key_file'] = ""

# Alternatively, if you don't provide a self-signed cert/key combo,
# this cookbook can also generate a self-signed cert and use that instead
default['caws-rundeck']['ssl_config']['org_unit']
default['caws-rundeck']['ssl_config']['org']
default['caws-rundeck']['ssl_config']['locality']
default['caws-rundeck']['ssl_config']['state']
default['caws-rundeck']['ssl_config']['country']

#default data bag configs for users/passwords
default['caws-rundeck']['data_bag_config']['bag_name'] = "rundeck-_default"
default['caws-rundeck']['data_bag_config']['users_bag_item'] = "rundeck_users"
default['caws-rundeck']['data_bag_config']['passwords_bag_item'] = "rundeck_passwords"
default['caws-rundeck']['data_bag_config']['framework_server_password_attribute'] = 'framework_server_password'
default['caws-rundeck']['data_bag_config']['mysql_server_password_attribute'] = 'mysql_server_password'
default['caws-rundeck']['data_bag_config']['jaas_passwords_attribute'] = 'jaas_passwords'
default['caws-rundeck']['data_bag_config']['encryption_password_attribute'] = 'encryption_password'
default['caws-rundeck']['data_bag_config']['rd_token_attribute'] = 'rd_token'

default['caws-rundeck']['data_bag_config']['ssl_bag_name'] = "rundeck-_default"
default['caws-rundeck']['data_bag_config']['ssl_passwords_bag_item'] = "rundeck_passwords"
default['caws-rundeck']['data_bag_config']['ssl_password_attribute'] = "ssl_password"
#OPTIONAL specify this if your source key has a password on it
#default['caws-rundeck']['data_bag_config']['ssl_src_key_password_attribute'] = "src_key_password"

# This attribute is only useful if including the `setup_jaas` recipe.
# The recipe will use the attribtue set here to create a JAAS login module
# using one or more authentication mechanisms.
# Each object that uses a password of some sort (LDAP/AD) should include
# a `name` attribute in the configuration object. This `name` attribute
# is used along with the `rundeck_passwords` encrypted data bag `jaas_passwords`
# object.
#
# For more info on object structure:
# - https://github.com/criteo-cookbooks/rundeck-server/blob/1.1.2/attributes/default.rb#L99
# - https://github.com/criteo-cookbooks/rundeck-server/blob/1.1.2/README.md
#
# For example, in the following object, the `PropertyFileLoginModule` does not need
# a `name` attribute because it holds no secrets. However, the `JettyCachingLdapLoginModule`
# does. :
#
# "caws-rundeck" : {
# "jaas" : [
# 	  {
# 	    "module":  "org.eclipse.jetty.plus.jaas.spi.PropertyFileLoginModule",
# 	    "flag":    "required",
# 	    "options": {
# 	      "debug": "true",
# 	      "file":  "/etc/rundeck/realm.properties"
# 	    }
# 	  },
# 	  {
# 	    "module" : "com.dtolabs.rundeck.jetty.jaas.JettyCachingLdapLoginModule",
# 	    "name" : "aws",
# 	    "flag":    "sufficient",
# 	    "options" : {
# 	      "debug" : "true",
# 	      "contextFactory" : "com.sun.jndi.ldap.LdapCtxFactory",
# 	      "providerUrl" : "ldap://some.ldap.server.com",
# 	      "bindDn" : "CN=LDAP Client User,OU=Service Accounts,OU=Rundeck,DC=aws,DC=us-east-1,DC=simple-ad-service,DC=internal",
# 	      "bindPassword" : "",
# 	      "authenticationMethod" : "simple",
# 	      "forceBindingLogin":"true",
# 	      "userBaseDn":"DC=aws,DC=us-east-1,DC=simple-ad-service,DC=internal",
# 	      "userRdnAttribute":"sAMAccountName",
# 	      "userIdAttribute":"sAMAccountName",
# 	      "userPasswordAttribute":"unicodePwd",
# 	      "userObjectClass":"user",
# 	      "roleBaseDn":"DC=aws,DC=us-east-1,DC=simple-ad-service,DC=internal",
# 	      "roleNameAttribute":"cn",
# 	      "roleMemberAttribute":"member",
# 	      "roleObjectClass":"group",
# 	      "cacheDurationMillis":"300000",
# 	      "reportStatistics":"true"
# 	    }
# 	  }
# 	]
# }
#
# And the encrypted data bag should look like the following:
# {
# 	"id" : "rundeck_passwords",
# 	"jaas_passwords" : {
# 		"aws" : { "bindPassword" : "Secret Here." }
# 	}
# }
#
# Note how the key in `jaas_passwords` matches the `name` attribute in the `jaas` object.
# Also notice that the keys in the hash in the `aws` object are keyed off the `options` object
# in the configuration. The values will be replaced when writing out the configuration file.
default['caws-rundeck']['jaas'] = [
	{
		"module" =>  "org.eclipse.jetty.plus.jaas.spi.PropertyFileLoginModule",
		"flag" =>   "required",
		"options" => {
			"debug" => "true",
			"file" =>  "/etc/rundeck/realm.properties"
	  }
	}
]
