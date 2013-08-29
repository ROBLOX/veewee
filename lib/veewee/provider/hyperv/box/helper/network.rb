module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        def add_network_switch (network_name = definition.hyperv_network_name)
          env.ui.info "Creating or reusing pre-existing VMSwitch [#{network_name}]"
          result = powershell_exec "$obj = Get-VMSwitch | Select -Property Name ; Foreach ($o in $obj) {if ($o.Name -eq '#{network_name}') {'reuse' ; exit}} ; New-VMSwitch -Name '#{network_name}' -EnableIov 1"
          status = (result.stdout.chomp 'reuse') ? true : false
          env.ui.info "VMSwitch [#{network_name}] already exists, re-using!" if status
        end

        def add_network_card (nic_name = definition.hyperv_nic_name, network_name = definition.hyperv_network_name, options = {:legacy => false})
          powershell_exec "Add-VMNetworkAdapter -VMName #{name} -Name '#{nic_name}' -DynamicMacAddress -SwitchName '#{network_name}' -IsLegacy $#{options[:legacy]}"
        end

        def remove_network_card (nic_name)
          powershell_exec "Remove-VMNetworkAdapter -VMName #{name} -Name '#{nic_name}'"
        end

      end
    end
  end
end