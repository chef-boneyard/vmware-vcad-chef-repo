Overview
========

Every Chef installation needs a Chef Repository. This one is for deploying the 3-tier Webapp demo with VMware vCloud Application Director.

Chef Repository
===============
This demonstration is intended for use with a Chef server. Upload the cookbooks managed with Berkshelf and the roles.

    berks upload --no-freeze --halt-on-frozen -b ./Berksfile
    knife role from file base.rb database.rb webapp.rb

vCloud Application Director
===========================
The files for VCAD are included in the repository. The "Chef-managed Service" installs the Chef client, `client.rb` and `/etc/chef/vcad.json` on the node. The node connects to the Chef server specified in the Properties for `chef_server_url` and `chef_server_organization` using the validation.pem at the `validation_key` URL. With the public IP address of the HAProxy server, you can visit the URLs http://IP/appd/ for the application or http://IP/haproxy for the HAProxy stats.
