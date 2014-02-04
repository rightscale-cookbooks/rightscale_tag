name             'rightscale_tag'
maintainer       'RightScale, Inc.'
maintainer_email 'cookbooks@rightscale.com'
license          'Apache 2.0'
description      'Installs/Configures rightscale_tag'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.0'

depends 'machine_tag', '~> 1.0.1'
depends 'marker', '~> 1.0.0'

recipe 'rightscale_tag::default', 'Tags a server with the standard RightScale server tags'
recipe 'rightscale_tag::monitoring', 'Tags a server with the RightScale monitoring server tag'
