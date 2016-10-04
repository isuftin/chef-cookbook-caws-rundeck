# caws-rundeck


This is a wrapper cookbook for the rundeck-server cookbook @ https://github.com/criteo-cookbooks/rundeck-server

This cookbook allows us to create encrypted data bags for secrets instead of dumping them into attributes. It also allows us to set the hostname properly for the machine it's deployed to as well as fine tune the machine post-deploy.

The encrypted data bag should be named `rundeck-<chef environment>` (ex: `rundeck-_default`) There should be one encrypted data bag with two items in the bag.

### Setting up users

Encrypted data bag item: `rundeck_users`

This data bag item should contain user credentials for a running server. If Rundeck is conncted via JAAS to AD/LDAP, this file will be the fallback for authentication for any given user. With no AD/LDAP scheme in place, flat file authentication will be the primary entry into Rundeck.

The format for the file is the user is the key in the hash and the credentials for the user (MD5 hashed password and group(s)) are the comma separated value portion. 

For MD5 hashing, see http://rundeck.org/docs/administration/authenticating-users.html#propertyfileloginmodule

Example:
```
{
	"id" : "rundeck_users",
	"admin" : "MD5:21232f297a57a5a743894a0e4a801fc3,user,admin,architect,deploy,build",
	"user" : "MD5:ee11cbb19052e40b07aac0ca060c23ee,user",
	"jsmith" : "MD5:a029d0df84eb5549c641e04a9ef389e5,user,admin"
}
```

In this example. for user `admin`, the password is `admin` hashed to MD5. User `admin` is in the following groups: `user,admin,architect,deploy,build`.

Encrypted data bag item: `rundeck_passwords`

This item contains the mysql server password, the password for the SSL keystore and the value for the framework server password ( See: http://rundeck.org/docs/administration/configuration-file-reference.html#framework.properties ).