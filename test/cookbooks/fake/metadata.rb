name             'fake'
maintainer       'RightScale, Inc.'
maintainer_email 'cookbooks@rightscale.com'
license          'Apache 2.0'
description      'Installs and tags fake servers for testing purposes'
version          '0.1.0'

depends 'rightscale_tag'

recipe 'fake::app_server', 'Prepares the test application server database'
recipe 'fake::db_server', 'Prepares the test database server database'
recipe 'fake::lb_server', 'Prepares the test load balancer server database'
