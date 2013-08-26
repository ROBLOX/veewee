module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        def build_info
          info=super
          info << { :filename => ".hyperv_version",
                    :content => "3.4" }
        end

        # Transfer information provide by the provider to the box
        #
        #
        def transfer_buildinfo(options)
          super(options)
          # with windows, we just use the mounted volume
          if not (definition.winrm_user && definition.winrm_password)
            iso_image='LinuxICv34.iso'
            env.ui.info "About to transfer hyperv guest additions iso to the box #{name} - #{ip_address} - #{ssh_options}"
            self.copy_to_box("#{File.join(env.config.veewee.iso_dir,iso_image)}",File.basename(iso_image))
          end
        end

      end
    end
  end
end
