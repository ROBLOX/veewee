module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        def ssh_options
          port=definition.ssh_host_port

          ssh_options={
              :user => definition.ssh_user,
              :port => port,
              :password => definition.ssh_password,
              :timeout => definition.ssh_login_timeout.to_i
          }
          return ssh_options

        end

      end
    end
  end
end
