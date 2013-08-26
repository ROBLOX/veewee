module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        def console_type(sequence)
          send_hyperv_sequence(sequence)
        end

        def send_hyperv_sequence(sequence)
          ui.info ""

          counter=0
          sequence.each { |s|
            counter=counter+1
            ui.info "Typing:[#{counter}]: #{s}"
            keycodes = Veewee::Provider::Hyperv::Util::Scancode.string_to_keycode(s)
            if keycodes.start_with?('0x')
              powershell_exec "$vmcs = Get-WmiObject -ComputerName #{definition.hyperv_host} -Namespace 'root\\virtualization' -Query 'SELECT * FROM MSVM_ComputerSystem WHERE ElementName like \\\"#{name}\\\" '; $vmkb = ($vmcs.getRelated('MSVM_Keyboard') | select-object) ; $cmd = $vmkb.TypeKey(#{keycodes})",{:remote => false}
            else
              powershell_exec "$vmcs = Get-WmiObject -ComputerName #{definition.hyperv_host} -Namespace 'root\\virtualization' -Query 'SELECT * FROM MSVM_ComputerSystem WHERE ElementName like \\\"#{name}\\\" '; $vmkb = ($vmcs.getRelated('MSVM_Keyboard') | select-object) ; $cmd = $vmkb.TypeText(\\\"#{keycodes}\\\")",{:remote => false}
            end
          }
        end

      end #Module
    end #Module
  end #Module
end #Module
