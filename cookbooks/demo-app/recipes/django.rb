#
# Cookbook Name:: demo-app
# Recipe:: django
#
# Copyright 2014, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if node.platform_family?('rhel')
  node.default['yum']['epel-testing']['enabled'] = true
  node.default['yum']['epel-testing']['managed'] = true
  include_recipe 'yum-epel'
end

include_recipe 'mysql::client'
include_recipe 'python'

%w{ Django MySQL-python }.each do |pkg|
  package pkg
end

directory "/var/www" do
  mode 0755
end

# create the project
execute "django-admin startproject demo_app" do
  cwd "/var/www"
  not_if {File.exists?("/var/www/demo_app")}
end

# find our database
database = search("node", "role:database AND chef_environment:#{node.chef_environment}")

# settings.py
template '/var/www/demo_app/demo_app/settings.py' do
  source 'settings.py.erb'
  mode '0644'
  variables(
    :db => database[0]
    )
end

# urls.py
template '/var/www/demo_app/demo_app/urls.py' do
  source 'urls.py.erb'
  mode '0644'
end

# python manage.py startapp appd
execute "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/mysql python manage.py startapp appd &>/tmp/startapp.log" do
  cwd "/var/www/demo_app"
  not_if {File.exists?("/var/www/demo_app/appd/views.py")}
end

# view.py
template '/var/www/demo_app/appd/views.py' do
  source 'views.py.erb'
  mode '0644'
  variables(
    :db => database[0]
    )
end

directory "/var/www/demo_app/appd/static" do
  mode 0755
end

#put the images in the apache directory
%w{chef.png vmware.jpg}.each do |image|
  cookbook_file "/var/www/demo_app/appd/static/#{image}" do
    source image
    mode '0644'
  end
end

# kill running django, not exactly daemonized
execute "pkill python" do
  action :nothing
  only_if "pgrep python"
  subscribes :run, "template[/var/www/demo_app/demo_app/urls.py]", :immediately
  subscribes :run, "template[/var/www/demo_app/demo_app/settings.py]", :immediately
  subscribes :run, "template[/var/www/demo_app/appd/views.py]", :immediately
end

# we'd really want to use runit or daemonize properly, but it's a demo
execute "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/mysql python manage.py runserver 0.0.0.0:80 &>>/tmp/django.log &" do
  cwd "/var/www/demo_app"
end
