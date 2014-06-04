#
# Cookbook Name:: demo-app
# Recipe:: haproxy
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

#node.override['haproxy']['admin']['address_bind'] = node['cloud']['public_ipv4']
node.override['haproxy']['admin']['address_bind'] = node['network']['interfaces']['eth1']['addresses'].keys.find { |e| /\./ =~ e }

package "haproxy"

pool_members = search("node", "role:#{node['haproxy']['app_server_role']} AND chef_environment:#{node.chef_environment}") || []

template "/etc/haproxy/haproxy.cfg" do
  source "haproxy.cfg.erb"
  owner "root"
  group "root"
  mode 00644
  variables(
    :pool_members => pool_members.uniq
    )
  notifies :reload, "service[haproxy]"
end

service "haproxy" do
  supports :restart => true, :status => true, :reload => true
  action [:enable, :start]
end
