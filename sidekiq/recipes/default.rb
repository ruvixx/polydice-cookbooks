#
# Cookbook Name:: sidekiq
# Recipe:: default
#

node[:deploy].each do |application, deploy|
  process_name = "sidekiq_#{application}"

  template "/usr/local/bin/count_sidekiq.sh" do
    source "count_sidekiq.sh.erb"
    owner 'root'
    group 'root'
    mode 0755
  end

  template "/etc/monit/conf.d/#{process_name}.monitrc" do
    source "monitrc.conf.erb"
    owner 'root'
    group 'root'
    mode 0644

    vars = {
      :env => deploy[:rails_env],
      :path => deploy[:deploy_to],
      :user => deploy[:user],
      :group => deploy[:group],
      :process_name => process_name,
      :custom_env => node[:custom_env][application],
    }
    if (node[:sidekiq] && node[:sidekiq][application])
      vars[:sidekiq] = node[:sidekiq][application]
    end

    variables vars
  end

  execute "ensure-sidekiq-is-setup-with-monit" do
    command %Q{
      monit -vv reload
    }
  end

  execute "restart-sidekiq" do
    command %Q{
      echo "sleep 20 && monit -vv -g #{process_name} restart all" | at now
    }
  end
end
