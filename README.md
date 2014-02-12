# rightscale_tag cookbook

[![Build Status](https://travis-ci.org/rightscale-cookbooks/rightscale_tag.png?branch=master)](https://travis-ci.org/rightscale-cookbooks/rightscale_tag)

This cookbook provides recipes and library methods for dealing with machine tags
in RightScale. It builds on the resources and library methods in the
[machine_tag] cookbook and provides a higher level set of functionality dealing
specifically with RightScale. In the future it will include support for defining
a 3-tier web application architecture on RightScale with machine tags.

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

# Attributes

There are no attributes in this cookbook.

# Recipes

## `rightscale_tag::default`

Sets the standard machine tags for a RightScale server which are `server:uuid`, `server:public_ip_X`, `server:private_ip_X` (where `X` is 0, 1, etc.).

## `rightscale_tag::monitoring`

Sets the standard machine tag to enable RightScale monitoring which is `rs_monitoring:state=active`. This should only be set when `collectd` or equivalent is sending data to RightScale (for more information see [rs-base]).

[rs-base]: https://github.com/rightscale-cookbooks/rs-base

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
    <td>Creates the tags required for the load balancer server</td>
    <td>Yes</td>
  </tr>
  <tr>
    <td><code>:delete</code></td>
    <td>Removes the tags from the load balancer server</td>
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
    <td>The name of the application the load balancer will serve</td>
    <td><code>name</code></td>
    <td>Yes</td>
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
    <td>Creates the tags required for the application server</td>
    <td>Yes</td>
  </tr>
  <tr>
    <td><code>:delete</code></td>
    <td>Removes the tags from the application server</td>
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
    <td>The name of the application</td>
    <td><code>name</code></td>
    <td>Yes</td>
  </tr>
  <tr>
    <td><code>bind_ip_address</code></td>
    <td>The IP address the application is bound to</td>
    <td></td>
    <td>Yes</td>
  </tr>
  <tr>
    <td><code>bind_port</code></td>
    <td>The port the application is bound to</td>
    <td></td>
    <td>Yes</td>
  </tr>
  <tr>
    <td><code>vhost_path</code></td>
    <td>The vhost or path of the application</td>
    <td></td>
    <td>Yes</td>
  </tr>
</table>

## `rightscale_tag_database`

A resource to create and remove tags to identify a database server including its role of master or slave.

### Actions

<table>
  <tr>
    <th>Actions</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><code>:create</code></td>
    <td>Creates the tags required for the database server</td>
    <td>Yes</td>
  </tr>
  <tr>
    <td><code>:delete</code></td>
    <td>Removes the tags from the database server</td>
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
    <td>The lineage of the database</td>
    <td><code>name</code></td>
    <td>Yes</td>
  </tr>
  <tr>
    <td><code>bind_ip_address</code></td>
    <td>The IP address the database is bound to</td>
    <td></td>
    <td>Yes</td>
  </tr>
  <tr>
    <td><code>bind_port</code></td>
    <td>The port the database is bound to</td>
    <td></td>
    <td>Yes</td>
  </tr>
  <tr>
    <td><code>role</code></td>
    <td>The role of the database; this can be <code>"master"</code> or <code>"slave"</code></td>
    <td></td>
    <td>No</td>
  </tr>
</table>

# Helpers

## `find_load_balancer_servers`

## `find_application_servers`

## `find_database_servers`

# Usage

# Author

Author:: RightScale, Inc. (<cookbooks@rightscale.com>)
