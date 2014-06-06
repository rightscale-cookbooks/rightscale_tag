name             'fake'
maintainer       'RightScale, Inc.'
maintainer_email 'cookbooks@rightscale.com'
license          'Apache 2.0'
description      'Installs and tags fake servers for testing purposes'
version          '0.1.0'

depends 'rightscale_tag'

recipe 'fake::load_balancer', 'Prepares the test load balancer server database'
recipe 'fake::application', 'Prepares the test application server database'
recipe 'fake::application_no_remote', 'Prepares the test application server database'
recipe 'fake::database', 'Prepares the test database server database'
