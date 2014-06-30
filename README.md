# rightscale_tag cookbook

[![Cookbook](https://img.shields.io/cookbook/v/rightscale_tag.svg?style=flat)][cookbook]
[![Release](https://img.shields.io/github/release/rightscale-cookbooks/rightscale_tag.svg?style=flat)][release]
[![Build Status](https://img.shields.io/travis/rightscale-cookbooks/rightscale_tag.svg?style=flat)][travis]

[cookbook]: https://supermarket.getchef.com/cookbooks/rightscale_tag
[release]: https://github.com/rightscale-cookbooks/rightscale_tag/releases/latest
[travis]: https://travis-ci.org/rightscale-cookbooks/rightscale_tag

This cookbook provides recipes, resources, providers, and library methods for
dealing with machine tags in RightScale. It builds on the resources and library
methods in the [machine_tag] cookbook and provides a higher level set of
functionality dealing specifically with RightScale. There are resources,
providers, and library methods for defining a 3-tier web application consisting
of load balancer, application, and database servers. The resources and providers
allow for setting up tags on the respective servers while the helper methods can
be used by other servers needing to find them.

For information about some of the machine tags used by this cookbook, see [List
of Instance RightScale Tags].

[List of Instance RightScale Tags]: http://support.rightscale.com/15-References/Machine_Tags/List_of_RightScale_Tags#Tags_for_Instances

Github Repository: [https://github.com/rightscale-cookbooks/rightscale_tag](https://github.com/rightscale-cookbooks/rightscale_tag)

# Requirements

* Requires Chef 11 or higher
* Requires Ruby 1.9 or higher
* Platform
  * Ubuntu 12.04
  * CentOS 6
* Cookbooks
  * [machine_tag]
  * [marker]

[machine_tag]: http://community.opscode.com/cookbooks/machine_tag
[marker]: http://community.opscode.com/cookbooks/marker

# Usage

On a RightScale server, add `rightscale_tag::default` to the run list. This will
use the `node['rightscale']['instance_uuid']` attribute to create the
`server:uuid` tag and the `node['cloud']['public_ips']` and
`node['cloud']['private_ips']` values  that come from the Ohai cloud plugin to
pupulate the `server:public_ip_X` and `server:private_ip_X` tags (where `X` is
0, 1, etc.).

The `rightscale_tag::monitoring` recipe should be placed in the run list after a
recipe setting up `collectd` or equivalent to send monitoring data to RightScale
or, alternatively, used with `include_recipe` at the end of a recipe doing that.

Please see the [rs-base] cookbook for how these recipes are used in RightScale
ServerTemplates.

[rs-base]: https://github.com/rightscale-cookbooks/rs-base

## 3-Tier Web Applications

This cookbook supports building a 3-tier web application deployment architecture
by providing an interface with tags on servers that can be set up with resources
and providers and searched for using helper methods. For a complete
implementation of a 3-tier LAMP stack using this cookbook, please see the
[rs-haproxy], [rs-application_php], and [rs-mysql] cookbooks.

[rs-haproxy]: https://github.com/rightscale-cookbooks/rs-haproxy
[rs-application_php]: https://github.com/rightscale-cookbooks/rs-application_php
[rs-mysql]: https://github.com/rightscale-cookbooks/rs-mysql

### Load Balancer Servers

The tags used for load balancer servers are as follows:

* **`load_balancer:active=true`** - specifies that the load balancer server
  is active
* **`load_balancer:active_<application_name>=true`** - specifies an application
  that the load balancer server serves; examples:
  `load_balancer:active_api=true`, `load_balancer:active_www=true`

These tags can be set up on a server using the [`rightscale_tag_load_balancer`]
resource and provider. For example, to tag a load balancer server for `api` and
`www` applications respectively in a recipe:

```ruby
rightscale_tag_load_balancer 'api'

rightscale_tag_load_balancer 'www'

# the server where this recipe is run will now have the following tags:
#   load_balancer:active=true
#   load_balancer:active_api=true
#   load_balancer:active_www=true
```

The [`find_load_balancer_servers`] method can be used to find tagged load
balancer servers. For example, to find load balancer servers for the `www`
application in a Chef recipe:

```ruby
class Chef::Recipe
  include Rightscale::RightscaleTag
end

lb_servers = find_load_balancer_servers(node, 'www')

# lb_servers will be a hash with contents like:
#   {
#     '01-ABCDEF123456' => {
#       'tags' => MachineTag::Set[
#         'load_balancer:active=true',
#         'load_balancer:active_www=true',
#         'server:public_ip_0=203.0.113.2',
#         'server:private_ip_0=10.0.0.2',
#         'server:uuid=01-ABCDEF123456'
#       ],
#       'application_names' => ['www'],
#       'public_ips' => ['203.0.113.2'],
#       'private_ips' => ['10.0.0.2']
#     }
#   }

lb_servers.each do |uuid, server_info|
  # here an application server could add each load balancer to its inbound
  # firewall rules using server_info['private_ips']
end
```

[`rightscale_tag_load_balancer`]: #rightscale_tag_load_balancer
[`find_load_balancer_servers`]: #find_load_balancer_servers

### Application Servers

The tags used for application servers are as follows:

* **`application:active=true`** - specifies that the application server is
  active
* **`application:active_<application_name>=true`** - specifies an application
  that the application server serves; examples: `application:active_api=true`,
  `application:active_www=true`
* **`application:bind_ip_address_<application_name>=<ip_address>`** - specifies
  the bind IP address of the application server; examples:
  `application:bind_ip_address_api=10.0.0.1`,
  `application:bind_ip_address_www=10.0.0.2`
* **`application:bind_port_<application_name>=<port>`** - specifies the bind
  port of the application server; examples: `application:bind_port_api=8080`,
  `application:bind_port_www=8080`
* **`application:vhost_path_<application_name=<vhost/path>`** - specifies the
  vhost or path name the application serves; examples:
  `application:vhost_path_api=api.example.com`, `application:vhost_path_www=/`

These tags can be set up on a server using the [`rightscale_tag_application`]
resource and provider. For example, to tag an application server for `api` and
`www` applications respectively in a recipe:

```ruby
rightscale_tag_application 'api' do
  bind_ip_address node['cloud']['private_ips'][0]
  bind_port 8080
  vhost_path 'api.example.com'
end

rightscale_tag_application 'www' do
  bind_ip_address node['cloud']['private_ips'][0]
  bind_port 8080
  vhost_path '/'
end

# the server where this recipe is run will now have the following tags:
#   application:active=true
#   application:active_api=true
#   application:active_www=true
#   application:bind_ip_address_api=10.0.0.1
#   application:bind_ip_address_www=10.0.0.1
#   application:bind_port_api=8080
#   application:bind_port_www=8080
#   application:vhost_path_api=api.example.com
#   application:vhost_path_www=/
```

The [`find_application_servers`] method can be used to find tagged application
servers. For example, to find application servers for the `www` application in a
Chef recipe:

```ruby
class Chef::Recipe
  include Rightscale::RightscaleTag
end

app_servers = find_application_servers(node, 'www')

# app_servers will be a hash with content like:
#   {
#     '01-ABCDEF7890123' => {
#       'tags' => MachineTag::Set[
#         'application:active=true',
#         'application:active_www=true',
#         'application:bind_ip_address_www=10.0.0.3',
#         'application:bind_port_www=8080',
#         'application:vhost_path_www=/',
#         'server:public_ip_0=203.0.113.3',
#         'server:private_ip_0=10.0.0.3',
#         'server:uuid=01-ABCDEF7890123'
#       ],
#       'applications' => {
#         'www' => {
#           'bind_ip_address' => '10.0.0.3',
#           'bind_port' => 8080,
#           'vhost_path' => '/',
#         }
#       },
#       'public_ips' => ['203.0.113.3'],
#       'private_ips' => ['10.0.0.3']
#     }
#   }

app_servers.each do |uuid, server_info|
  # here a load balancer server could add application servers to its
  # configuration using the values in server_info['applications']['www']
end
```

[`rightscale_tag_application`]: #rightscale_tag_application
[`find_application_servers`]: #find_application_servers

### Database Servers

The tags used for database servers are as follows:

* **`database:active=true`** - specifies that a server is an active database
  server
* **`database:lineage=<lineage>`** - specifies the lineage of the database
  server; examples: `database:lineage=production`, `database:lineage=staging`
* **`database:master_active=<timestamp>`** - specifies that the database server
  is an active master since `timestamp`; a timestamp is the number of seconds
  since the UNIX epoch; examples: `database:master_active=1391473172` (in this
  case the timestamp represents 2014-02-04 00:19:32 UTC)
* **`database:slave_active=<timestamp>`** - specifies that the database server
  is an active slave since `timestamp`; a timestamp is the number of seconds
  since the UNIX epoch; examples: `database:slave_active=1391473672` (in this
  case the timestamp represents 2014-02-04 00:27:52 UTC)
* **`database:bind_ip_address=<ip_address>`** - specifies the bind IP address
  of the database server; examples: `database:bind_ip_address=10.0.0.4`
* **`database:bind_port=<port>`** - specifies the bind port of the database
  server; examples: `database:bind_port=3306`

These tags can be set up on a server using the [`rightscale_tag_database`]
resource and provider. For example, to tag a database server for the `staging`
lineage as a master in a recipe:

```ruby
rightscale_tag_database 'staging' do
  role 'master'
  bind_ip_address node['cloud']['private_ips'][0]
  bind_port 3306
end

# the server where this recipe is run will now have the following tags:
#   database:active=true
#   database:lineage=staging
#   database:master_active=1391473172
#   database:bind_ip_address=10.0.0.1
#   database:bind_port=3306
```

The [`find_database_servers`] method can be used to find tagged database
servers. For example, to find the master database server for the `staging`
lineage in a Chef recipe:

```ruby
class Chef::Recipe
  include Rightscale::RightscaleTag
end

db_servers = find_database_servers(node, 'staging', 'master', only_latest_for_role: true)

# db_servers will be a hash with content like:
#   {
#     '01-ABCDEF4567890' => {
#       'tags' => MachineTag::Set[
#         'database:active=true',
#         'database:master_active=1391803034',
#         'database:lineage=example',
#         'server:public_ip_0=203.0.113.4',
#         'server:private_ip_0=10.0.0.4',
#         'server:uuid=01-ABCDEF4567890'
#       ],
#       'lineage' => 'example',
#       'bind_ip_address' => '10.0.0.4',
#       'bind_port' => 3306,
#       'role' => 'master',
#       'master_since' => Time.at(1391803034),
#       'public_ips' => ['203.0.113.4'],
#       'private_ips' => ['10.0.0.4']
#     }
#   }

db_servers.each do |uuid, server_info|
  # here a slave database server could set up replication from the master using
  # server_info['bind_ip_address'] and server_info['bind_port']
end
```

[`rightscale_tag_database`]: #rightscale_tag_database
[`find_database_servers`]: #find_database_servers

# Attributes

There are no attributes in this cookbook.

# Recipes

## `rightscale_tag::default`
Sets the standard machine tags for a RightScale server which are `server:uuid`,
`server:public_ip_X`, `server:private_ip_X` (where `X` is 0, 1, etc.).

## `rightscale_tag::monitoring`

Sets the standard machine tag to enable RightScale monitoring which is
`rs_monitoring:state=active`. This should only be set when `collectd` or
equivalent is sending data to RightScale (for more information see [rs-base]).

# Resources/Providers

## `rightscale_tag_load_balancer`

A resource to create and remove tags to identify a load balancer server.

### Actions

| Actions | Description | Default |
| --- | --- | --- |
| `:create` | creates the tags required for the load balancer server | yes |
| `:delete` | removes the tags from the load balancer server | |

### Attributes

| Attribute | Description | Default Value | Required |
| --- | --- | --- | --- |
| `application_name` | the name of the application the load balancer will serve | | yes |

## `rightscale_tag_application`

A resource to create and remove tags to identify an application server.

### Actions

| Actions | Description | Default |
| --- | --- | --- |
| `:create` | creates the tags required for the application server | yes |
| `:delete` | removes the tags from the application server | |

### Attributes

| Attribute | Description | Default Value | Required |
| --- | --- | --- | --- |
| `application_name` | the name of the application | | yes |
| `bind_ip_address` | the IP address the application is bound to | | yes |
| `bind_port` | the port the application is bound to | | yes |
| `vhost_path | the vhost or path of the application | | yes |

## `rightscale_tag_database`

A resource to create and remove tags to identify a database server including its
role of master or slave.

### Actions

| Actions | Description | Default |
| --- | --- | --- |
| `:create` | creates the tags required for the database server | yes |
| `:delete` | removes the tags from the database server | |

### Attributes

| Attribute | Description | Default Value | Required |
| --- | --- | --- | --- |
| `lineage` | the lineage of the database | | yes |
| `bind_ip_address` | the IP address the database is bound to | | yes |
| `bind_port` | the port the database is bound to | | yes |
| `role` | the role of the database; this can be `'master'` or `'slave'` | | no |

# Helpers

This cookbook also provides three helper methods for finding servers of each
type. To use them in a recipe add the following:

```ruby
class Chef::Recipe
  include RightScale::RightScaleTag
end
```

## `find_load_balancer_servers`

Find load balancer servers using tags. This will find all active load balancer
servers, or, if `application_name` is given, it will find all load balancer
servers serving for that application.

```ruby
def find_load_balancer_servers(node, application_name = nil, options = {})
```

### Parameters

| Name | Description | Type |
| --- | --- | --- |
| `node` | the Chef node | `Chef::Node` |
| `application_name` | the name of the application served by load balancer servers to search for; this is an optional parameter | `String` |
| `options` | optional parameters | `Hash` |
| `options[:query_timeout]` | the seconds to timeout for the query operation; the default is `120` | `Integer` |

## `find_application_servers`

Find application servers using tags. This will find all active application
servers, or, if `application_name` is given, it will find all application
servers serving that application.

```ruby
def find_application_servers(node, application_name = nil, options = {})
```

### Parameters

| Name | Description | Type |
| --- | --- | --- |
| `node` | the Chef node | `Chef::Node` |
| `application_name` | the name of the application served by the application servers to search for; this is an optional parameter | `String` |
| `options` | optional parameters | `Hash` |
| `options[:query_timeout]` | the seconds to timeout for the query operation; the default is `120` | `Integer` |

## `find_database_servers`

Find database servers using tags. This will find all active database servers,
or, if `lineage` is given, it will find all database servers for that linage,
or, if `role` is specified it will find the database server(s) with that role.

```ruby
def find_database_servers(node, lineage = nil, role = nil, options = {})
```

### Parameters

| Name | Description | Type |
| --- | --- | --- |
| `node` | the Chef node | `Chef::Node` |
| `lineage` | the lineage of the database servers to search for; this is an optional parameter | `String` |
| `role` | the role of the database servers to search for; this should be `'master'` or `'slave'`; this is an optional parameter | `String` |
| `options` | optional parameters | `Hash` |
| `options[:only_latest_for_role]` | only return the latest server tagged for a role; the default is `false` | `Boolean` |
| `options[:query_timeout]` | the seconds to timeout for the query operation; the default is `120` | `Integer` |

# Author

Author:: RightScale, Inc. (<cookbooks@rightscale.com>)
