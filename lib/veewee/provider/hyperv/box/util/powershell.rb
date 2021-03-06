module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        def powershell_exec(scriptblock,options = {:remote => true})

          raise Veewee::Error,"Empty scriptblock passed to powershell_exec" unless scriptblock

          defaults = {:mute => true,:status => 0,:stderr => "&1"}
          options = defaults.merge(options)

          scriptblock = scriptblock.gsub('|', '^|')


          if options[:remote]
            return shell_exec("powershell -Command Invoke-Command -Computername #{definition.hyperv_host} -ScriptBlock {#{scriptblock}}",options)
          else
            return shell_exec("powershell -Command #{scriptblock}",options)
          end
        end

      end
    end
  end
end
