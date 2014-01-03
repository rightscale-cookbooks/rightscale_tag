# rs-machine_tag cookbook

[![Build Status](https://travis-ci.org/rightscale-cookbooks/rs-machine_tag.png?branch=master)](https://travis-ci.org/rightscale-cookbooks/rs-machine_tag)

This cookbook provides recipes and library methods for dealing with machine tags
in RightScale. It builds on the resources and library methods in the
[machine_tag] cookbook and provides a higher level set of functionality dealing
specifically with RightScale. In the future it will include support for defining
a 3-tier web application architecture on RightScale with machine tags.

For information about some of the machine tags used by this cookbook, see [List
of Instance RightScale Tags].

[List of Instance RightScale Tags]: http://support.rightscale.com/15-References/Machine_Tags/List_of_RightScale_Tags#Tags_for_Instances

# Requirements

* Chef 11 or above
* [machine_tag] cookbook
* [marker] cookbook

[machine_tag]: https://github.com/rightscale-cookbooks/machine_tag
[marker]: https://github.com/rightscale-cookbooks/marker

# Usage

On a RightScale server, add `rs-machine_tag::default` to the run list. This will
use the `node['rightscale']['instance_uuid']` attribute to create the
`server:uuid` tag and the `node['cloud']['public_ips']` and
`node['cloud']['private_ips']`values  that come from the Ohai cloud plugin to
pupulate the `server:public_ip_X` and `server:private_ip_X` tags (where `X` is 
0, 1, etc.).

The `rs-machine_tag::monitoring` recipe should be placed in the run list after a
recipe setting up `collectd` or equivalent to send monitoring data to RightScale
or, alternatively, used with `include_recipe` at the end of a recipe doing that.

Please see the [rs-base] cookbook for how these recipes are used in RightScale
ServerTemplates.

# Attributes

There are no attributes in this cookbook.

# Recipes

## default

Sets the standard machine tags for a RightScale server which are `server:uuid`, `server:public_ip_X`, `server:private_ip_X` (where `X` is 0, 1, etc.).

## monitoring

Sets the standard machine tag to enable RightScale monitoring which is `rs_monitoring:state=active`. This should only be set when `collectd` or equivalent is sending data to RightScale (for more information see [rs-base]).

[rs-base]: https://github.com/rightscale-cookbooks/rs-base

# Author

Author:: RightScale, Inc. (<cookbooks@rightscale.com>)
