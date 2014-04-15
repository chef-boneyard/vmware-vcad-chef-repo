#Success
Blueprint has been successfully imported in vCloud Application Director.

###Deployment steps:
1. The roles and cookbooks from the https://github.com/chef-partners/vmware-vcad-chef-repo will need to be uploaded to your Chef server.

    berks upload --no-freeze --halt-on-frozen -b ./Berksfile
    knife role from file base.rb database.rb webapp.rb

2. Click on deploy to deploy the application.

3. Enter name for deployment profile.

4. You will need to enter your chef_server_organization and the URL to your validation.pem if you are using Hosted Enterprise Chef. If you are using an Enterprise or open source Chef server you will need to update the chef_server_url.

###Smoke test after deployment:
You may enter the IP address of the HAProxy server with the URL "http://server_IP/appd/" and it will redirect you to one of the application servers. You may add "/haproxy" to the end of the HAProxy IP address URL to reach the HAProxy Statistics Report. The pages for the application servers contain dynamically generated content from the Chef client run and the Django application, demonstrating a successful deployment.
