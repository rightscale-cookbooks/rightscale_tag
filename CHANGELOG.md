rightscale_tag Cookbook CHANGELOG
=======================

This file is used to list changes made in each version of the rightscale_tag cookbook.

v2.0.2
------

- Adding a generic application server tagging recipe

v2.0.1
------

- Adding in support for azurerm

v2.0.0
------

- Remove support for chef 11, add support for chef 12
- Remove Strainer tests and replace with rake tests.

v1.2.1
------

- Updated to use machine_tag-1.2.1
- Tag Scope limited to operational instances
- Tag Scope limited to cloud of instance making call

v1.2.0
------

- Updated to use machine_tag-1.2.0 - support for multiple tags, and match_all

v1.1.0
------

- Support for RL10

v1.0.6
------

- Remove workaround logic to handle cloudstack behaviour with IP addresses.

v1.0.5
------

- Add logic in default recipe to handle cloudstack behaviour with IP addresses.

v1.0.4
------

- Check IP addresses if they are private IPs before setting server:public_ip_# and server:private_ip_#.

v1.0.3
------

- Add testing for support of Ubuntu 14.04, CentOS 7.0, and RedHat Enterprise Linux 7.0.

v1.0.2
------

- Updated README
- Added ChefSpec matchers

v1.0.1
------

- Initial release to the community
