# rightscale_tag cookbook

[![Build Status](https://travis-ci.org/rightscale-cookbooks/rightscale_tag.png?branch=master)](https://travis-ci.org/rightscale-cookbooks/rightscale_tag)

This cookbook provides recipes, resources, providers, and library methods for
dealing with machine tags in RightScale. It builds on the resources and library
methods in the [machine_tag] cookbook and provides a higher level set of
functionality dealing specifically with RightScale. There are resources,
providers, and library methods for definign a 3-tier web application consisting
of load balancer, application, and database servers. The resources and providers
allow for setting up tags on the respective servers while the helper methods can
be used by other servers needing to find them.

For information about some of the machine tags used by this cookbook, see [List
of Instance RightScale Tags].

[List of Instance RightScale Tags]: http://support.rightscale.com/15-References/Machine_Tags/List_of_RightScale_Tags#Tags_for_Instances

Github Repository: [https://github.com/rightscale-cookbooks/rightscale_tag](https://github.com/rightscale-cookbooks/rightscale_tag)

# Requirements

* Requires Chef 11 or higher
* Platform
  * Ubuntu 12.04
  * CentOS 6.4
* Cookbooks
  * [machine_tag]
  * [marker]

[machine_tag]: https://github.com/rightscale-cookbooks/machine_tag
[marker]: https://github.com/rightscale-cookbooks/marker

# Usage

On a RightScale server, add `rightscale_tag::default` to the run list. This will
use the `node['rightscale']['instance_uuid']` attribute to create the
`server:uuid` tag and the `node['cloud']['public_ips']` and
`node['cloud']['private_ips']`values  that come from the Ohai cloud plugin to
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

================================================================================

* **`load_balancer:active_<application_name>=true`** - specifies an application that the load balancer server serves; examples: `load_balancer:active_api=true`, `load_balancer:active_www=true`

### Application Servers

================================================================================

* **`application:active_<application_name>=true`** - specifies an application that the application server serves; examples: `application:active_api=true`, `application:active_www=true`
* **`application:bind_ip_address_<application_name>=<ip_address>`** - specifies the bind IP address of the application server; examples: `application:bind_ip_address_api=192.0.2.1`, `application:bind_ip_address_www=192.0.2.2`
* **`application:bind_port_<application_name>=<port>`** - specifies the bind port of the application server; examples: `application:bind_port_api=8080`, `application:bind_port_www=8080`
* **`application:vhost_path_<application_name=<vhost/path>`** - specifies the vhost or path name the application serves; examples: `application:vhost_path_api=api.example.com`, `application:vhost_path_www=/`

### Database Servers

================================================================================

* **`database:active=true`** - specifies that a server is an active database server
* **`database:lineage=<lineage>`** - specifies the lineage of the database server; example: `database:lineage=production`
* **`database:master_active=<timestamp>`** - specifies that the database server is an active master since timestamp

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

<table>
  <tr>
    <th>Actions</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><code>:create</code></td>
    <td>creates the tags required for the load balancer server</td>
    <td>yes</td>
  </tr>
  <tr>
    <td><code>:delete</code></td>
    <td>removes the tags from the load balancer server</td>
    <td></td>
  </tr>
</table>

### Attributes

<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default Value</th>
    <th>Required</th>
  </tr>
  <tr>
    <td><code>application_name</code></td>
    <td>the name of the application the load balancer will serve</td>
    <td><code>name</code></td>
    <td>yes</td>
  </tr>
</table>

## `rightscale_tag_application`

A resource to create and remove tags to identify an application server.

### Actions

<table>
  <tr>
    <th>Actions</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><code>:create</code></td>
    <td>creates the tags required for the application server</td>
    <td>yes</td>
  </tr>
  <tr>
    <td><code>:delete</code></td>
    <td>removes the tags from the application server</td>
    <td></td>
  </tr>
</table>

### Attributes

<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default Value</th>
    <th>Required</th>
  </tr>
  <tr>
    <td><code>application_name</code></td>
    <td>the name of the application</td>
    <td><code>name</code></td>
    <td>yes</td>
  </tr>
  <tr>
    <td><code>bind_ip_address</code></td>
    <td>the IP address the application is bound to</td>
    <td></td>
    <td>yes</td>
  </tr>
  <tr>
    <td><code>bind_port</code></td>
    <td>the port the application is bound to</td>
    <td></td>
    <td>yes</td>
  </tr>
  <tr>
    <td><code>vhost_path</code></td>
    <td>the vhost or path of the application</td>
    <td></td>
    <td>yes</td>
  </tr>
</table>

## `rightscale_tag_database`

A resource to create and remove tags to identify a database server including its
role of master or slave.

### Actions

<table>
  <tr>
    <th>Actions</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><code>:create</code></td>
    <td>creates the tags required for the database server</td>
    <td>yes</td>
  </tr>
  <tr>
    <td><code>:delete</code></td>
    <td>removes the tags from the database server</td>
    <td></td>
  </tr>
</table>

### Attributes

<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default Value</th>
    <th>Required</th>
  </tr>
  <tr>
    <td><code>lineage</code></td>
    <td>the lineage of the database</td>
    <td><code>name</code></td>
    <td>yes</td>
  </tr>
  <tr>
    <td><code>bind_ip_address</code></td>
    <td>the IP address the database is bound to</td>
    <td></td>
    <td>yes</td>
  </tr>
  <tr>
    <td><code>bind_port</code></td>
    <td>the port the database is bound to</td>
    <td></td>
    <td>yes</td>
  </tr>
  <tr>
    <td><code>role</code></td>
    <td>the role of the database; this can be <code>'master'</code> or <code>'slave'</code></td>
    <td></td>
    <td>no</td>
  </tr>
</table>

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

<table>
  <tr>
    <th>Name</th>
    <th>Description</th>
    <th>Type</th>
  </tr>
  <tr>
    <td><code>node</code></td>
    <td>the Chef node</td>
    <td><code>Chef::Node</code></td>
  </tr>
  <tr>
    <td><code>application_name</code></td>
    <td>the name of the application served by load balancer servers to search for; this is an optional parameter</td>
    <td><code>String</code></td>
  </tr>
  <tr>
    <td><code>options</code></td>
    <td>optional parameters</td>
    <td><code>Hash</code></td>
  </tr>
  <tr>
    <td><code>options[:query_timeout]</code></td>
    <td>the seconds to timeout for the query operation; the default is `120`</td>
    <td><code>Integer</code></td>
  </tr>
</table>

## `find_application_servers`

Find application servers using tags. This will find all active application
servers, or, if `application_name` is given, it will find all application
servers serving that application.

```ruby
def find_application_servers(node, application_name = nil, options = {})
```

### Parameters

<table>
  <tr>
    <th>Name</th>
    <th>Description</th>
    <th>Type</th>
  </tr>
  <tr>
    <td><code>node</code></td>
    <td>the Chef node</td>
    <td><code>Chef::Node</code></td>
  </tr>
  <tr>
    <td><code>application_name</code></td>
    <td>the name of the application served by the application servers to search for; this is an optional parameter</td>
    <td><code>String</code></td>
  </tr>
  <tr>
    <td><code>options</code></td>
    <td>optional parameters</td>
    <td><code>Hash</code></td>
  </tr>
  <tr>
    <td><code>options[:query_timeout]</code></td>
    <td>the seconds to timeout for the query operation; the default is `120`</td>
    <td><code>Integer</code></td>
  </tr>
</table>

## `find_database_servers`

Find database servers using tags. This will find all active database servers,
or, if `lineage` is given, it will find all database servers for that linage,
or, if `role` is specified it will find the database server(s) with that role.

```ruby
def find_database_servers(node, lineage = nil, role = nil, options = {})
```

### Parameters

<table>
  <tr>
    <th>Name</th>
    <th>Description</th>
    <th>Type</th>
  </tr>
  <tr>
    <td><code>node</code></td>
    <td>the Chef node</td>
    <td><code>Chef::Node</code></td>
  </tr>
  <tr>
    <td><code>lineage</code></td>
    <td>the lineage of the database servers to search for; this is an optional parameter</td>
    <td><code>String</code></td>
  </tr>
  <tr>
    <td><code>role</code></td>
    <td>the role of the database servers to search for; this should be <code>'master'</code> or <code>'slave'</code>; this is an optional parameter</td>
    <td><code>String</code></td>
  </tr>
  <tr>
    <td><code>options</code></td>
    <td>optional parameters</td>
    <td><code>Hash</code></td>
  </tr>
  <tr>
    <td><code>options[:query_timeout]</code></td>
    <td>the seconds to timeout for the query operation; the default is `120`</td>
    <td><code>Integer</code></td>
  </tr>
</table>

# Author

Author:: RightScale, Inc. (<cookbooks@rightscale.com>)
