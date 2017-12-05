#
# Cookbook:: deepspace
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#
# Cookbook Name:: deepspace
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

# Runs apt-get update
include_recipe "apt"
include_recipe "java_se"

# Install Tomcat 7
apt_package 'tomcat7' do
    action :install
end

# Set tomcat port 
script 'tomcat_port' do 
    interpreter "bash"
    code "sed -i 's/Connector port=\".*\" protocol=\"HTTP\\/1.1\"$/Connector port=\"#{node['tomcat']['deepspace_port']}\" protocol=\"HTTP\\/1.1\"/g' /etc/tomcat7/server.xml"
    not_if "grep 'Connector port=\"#{node['tomcat']['deepspace_port']}\" protocol=\"HTTP/1.1\"$' /etc/tomcat7/server.xml"
    notifies :restart, "service[tomcat7]", :immediately
end

# Install the deepspace app, restart the Tomcat service if necessary
remote_file 'deepspace_app' do
    source 'https://************.visualstudio.com/_apis/resources/Containers/385355?itemPath=drop%2Ftarget%2FDeepspace.war'
    path '/var/lib/tomcat7/webapps/ROOT.war'
    action :create
    notifies :restart, "service[tomcat7]", :immediately
end

# Ensure Tomcat is running
service 'tomcat7' do
    action :start
end

