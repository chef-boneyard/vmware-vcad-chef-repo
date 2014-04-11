name "demo-app"
maintainer       "Chef Software, Inc."
maintainer_email "matt@getchef.com"
license          "Apache 2.0"
description      "VMware demonstration application."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

depends "apache2"
