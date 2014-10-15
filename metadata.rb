name             'rightscale_tag'
maintainer       'RightScale, Inc.'
maintainer_email 'cookbooks@rightscale.com'
license          'Apache 2.0'
description      'Provides LWRPs and helper methods for building 3-tier applications using machine tags in RightScale'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.3'

depends 'machine_tag', '~> 1.0.3'
depends 'marker', '~> 1.0.0'

recipe 'rightscale_tag::default', 'Tags a server with the standard RightScale server tags'
recipe 'rightscale_tag::monitoring', 'Tags a server with the RightScale monitoring server tag'
