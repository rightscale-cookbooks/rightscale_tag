name             'rightscale_tag'
maintainer       'RightScale, Inc.'
maintainer_email 'cookbooks@rightscale.com'
license          'Apache 2.0'
description      'Provides LWRPs and helper methods for building 3-tier applications using machine tags in RightScale'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '2.0.1'
issues_url       'https://github.com/rightscale-cookbooks/rightscale_tag/issues'
source_url       'https://github.com/rightscale-cookbooks/rightscale_tag'

depends 'machine_tag', '~> 2.0'
depends 'marker', '~> 2.0'

recipe 'rightscale_tag::default', 'Tags a server with the standard RightScale server tags'
recipe 'rightscale_tag::monitoring', 'Tags a server with the RightScale monitoring server tag'
