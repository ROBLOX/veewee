module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        def add_network_switch
          result = powershell_exec("Get-VMSwitch^|Select -Property Name")
          powershell_exec("New-VMSwitch -Name #{definition.hyperv_network_name} -NetAdapterName #{definition.hyperv_host_nic}") unless result.stdout.include? "#{definition.hyperv_network_name}"
        end

        def add_network_card
          #TODO: Probably need to separate switch vlan names from nic names
          result = powershell_exec("get-VMNetworkAdapter -VMName #{name}^|Select -Property Name")
          powershell_exec("Add-VMNetworkAdapter -VMName #{name} -Name #{definition.hyperv_network_name} -DynamicMacAddress") unless result.stdout.include? "#{definition.hyperv_network_name}"
        end

        def add_ssh_nat_mapping
          unless definition.nil?
            unless definition.skip_nat_mapping
              #Map SSH Ports
              if self.running?
                command="#{@vboxcmd} controlvm \"#{name}\" natpf#{self.natinterface} \"guestssh,tcp,,#{definition.ssh_host_port},,#{definition.ssh_guest_port}\""
              else
                command="#{@vboxcmd} modifyvm \"#{name}\" --natpf#{self.natinterface} \"guestssh,tcp,,#{definition.ssh_host_port},,#{definition.ssh_guest_port}\""
              end
              shell_exec("#{command}")
            end
          end
        end

        def add_winrm_nat_mapping
          unless definition.nil?
            #Map WinRM Ports
            unless definition.skip_nat_mapping
              if self.running?
                command="#{@vboxcmd} controlvm \"#{name}\" natpf#{self.natinterface} \"guestwinrm,tcp,,#{definition.winrm_host_port},,#{definition.winrm_guest_port}\""
              else
                command="#{@vboxcmd} modifyvm \"#{name}\" --natpf#{self.natinterface} \"guestwinrm,tcp,,#{definition.winrm_host_port},,#{definition.winrm_guest_port}\""
              end
              shell_exec("#{command}")
            end
          end
        end

      end
    end
  end
end