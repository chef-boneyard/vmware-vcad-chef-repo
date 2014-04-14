#
# Cookbook Name:: demo-app
# Recipe:: default
#
# Copyright 2012-2014, Chef Software, Inc.
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

include_recipe "apache2"

directory "/var/www/demo-app" do
  mode 0755
end

#put the images in the apache directory
%w{chef.png vmware.jpg}.each do |image|
  cookbook_file "/var/www/demo-app/#{image}" do
    source image
    mode '0644'
  end
end

db = search(:node, 'run_list:recipe\[mysql\:\:server\]') || []

#write out the webpage
template '/var/www/demo-app/index.html' do
  source 'index.html.erb'
  mode '0644'
  variables(
    :mysql => db.uniq
    )
end

web_app 'demo-app' do
  cookbook 'apache2'
  server_name node['cloud']['public_hostname']
  server_aliases [node['cloud']['public_ipv4']]
  directory_options ['Indexes', 'FollowSymLinks']
  docroot '/var/www/demo-app'
end
