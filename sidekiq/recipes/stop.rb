#
# Cookbook Name:: sidekiq
# Recipe:: stop
#

node[:deploy].each do |application, deploy|
  execute "stop-sidekiq" do
    command %Q{
      monit -g sidekiq_#{application} stop all
    }
  end
end
