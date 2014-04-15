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

# kill running django on template update
execute "pkill python" do
  ignore_failure true
  action :nothing
  subscribes :run, "template[/var/www/demo_app/demo_app/urls.py]"
  subscribes :run, "template[/var/www/demo_app/demo_app/settings.py]"
end

# python manage.py startapp appd
execute "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/mysql python manage.py startapp appd" do
  cwd "/var/www/demo_app"
  action :nothing
  subscribes :run, "template[/var/www/demo_app/demo_app/urls.py]"
  subscribes :run, "template[/var/www/demo_app/demo_app/settings.py]"
end

# update config
execute "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/mysql python manage.py syncdb" do
  cwd "/var/www/demo_app"
  action :nothing
  subscribes :run, "template[/var/www/demo_app/demo_app/urls.py]"
  subscribes :run, "template[/var/www/demo_app/demo_app/settings.py]"
end

# we'd really want to use runit or daemonize properly, but it's a demo
execute "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/mysql python manage.py runserver 0.0.0.0:8080 &" do
  cwd "/var/www/demo_app"
  action :nothing
  subscribes :run, "execute[LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/mysql python manage.py syncdb]"
end

include_recipe "demo-app::static"
