module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        def host_ip_as_seen_by_guest
          return definition.host_ip_as_seen_by_box if definition.host_ip_as_seen_by_box
          return self.get_local_ip
        end

        # Get the IP address of the box
        def ip_address
          if definition.box_ip
            return definition.box_ip
          else
            return '127.0.0.1'
          end
        end

        # Get the mac address of the box
        def get_mac_address
          results = powershell_exec "(Get-VMNetworkAdapter -VMName #{name}).MacAddress | Format-List"
          mac = results.stdout.chomp
          return mac
        end

      end
    end
  end
end
