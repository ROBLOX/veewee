module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        def exists?
          check?(:exists)
        end

        def running?
          check?(:running)
        end

        private

        def check? type
          case type
            when :exists
              result = powershell_exec "$obj = Get-VM | Select -Property VMName ; Foreach ($o in $obj) {if ($o.VMName -eq '#{name}') {'true' ; exit}} 'false'"
              status = (result.stdout.chomp == 'true') ? true : false
            when :running
              result = powershell_exec "(Get-VM #{name}).State | Format-List"
              status = (result.stdout.chomp == 'Running') ? true : false
            else
              env.ui.info "Unsupported check type #{type} specified"
              status = false
          end
          status
        end
      end
    end
  end
end
