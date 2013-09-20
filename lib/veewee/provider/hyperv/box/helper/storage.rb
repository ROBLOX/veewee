module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        #TODO: def add_shared_folder
        #  command="#{@vboxcmd} sharedfolder add  \"#{name}\" --name \"veewee-validation\" --hostpath \"#{File.expand_path(env.validation_dir)}\" --automount"
        #  shell_exec("#{command}")
        #end

        def add_controller(controller_kind)
          case controller_kind
            when 'scsi'
              powershell_exec("Add-VMScsiController -VMName #{name}")
            else
              env.logger.warn("Hyper-V currently only supports (up to 12) additional SCSI controllers on top of the 2 default IDE controllers")
          end
        end

        def create_disk
          vm_path = File.join(definition.hyperv_store_path,name).gsub('/', '\\').downcase
          1.upto(definition.disk_count.to_i) do |f|
            unless definition.disk_format.downcase == 'vhdx'
              env.ui.warn "HyperV only support the VHDX virtual hard drive format, changing from [#{definition.disk_format}]"
              definition.disk_format = 'vhdx'
            end
            env.ui.info "Creating new Dynamic HD #{definition.disk_size}MB - PhysicalSectorSizeBytes #{definition.disk_physical_sector_size} - LogicalSectorSizeBytes #{definition.disk_logical_sector_size}"
            vhd_path = File.join(vm_path,"#{name}-#{f}.#{definition.disk_format}").gsub('/', '\\').downcase
            powershell_exec "New-VHD -Path '#{vhd_path}' -SizeBytes #{definition.disk_size}MB -Dynamic" #" -PhysicalSectorSizeBytes #{definition.disk_physical_sector_size} -LogicalSectorSizeBytes #{definition.disk_logical_sector_size}"
          end
        end

        def attach_disk(controller_kind, device_number)
          vm_path = File.join(definition.hyperv_store_path,name).gsub('/', '\\').downcase
          1.upto(definition.disk_count.to_i) do |f|
            vhd_path = File.join(vm_path,"#{name}-#{f}.#{definition.disk_format}").gsub('/', '\\').downcase
            env.ui.info "Attaching Dynamic HD #{vhd_path} to VM #{name} on #{controller_kind} controller # #{device_number}"
            powershell_exec "Add-VMHardDiskDrive -VMName #{name} -Path '#{vhd_path}' -ControllerType #{controller_kind} "
          end
        end

        def attach_isofile(device_number = 0,port = 0,iso_file = definition.iso_file)
          local_file = File.join(env.config.veewee.iso_dir,iso_file).gsub('/', '\\')
          remote_file = File.join("\\\\",definition.hyperv_host,'veewee',iso_file ).gsub('/', '\\')
          env.ui.info "Copying ISO file [#{local_file}] to HyperV Host"
          result = powershell_exec "if (Test-Path -Path '#{remote_file}') {'true' ; exit} else {Copy-Item -Path '#{local_file}' -Destination '#{remote_file}'}",{:remote => false}
          status = (result.stdout.chomp == 'true') ? true : false
          env.ui.info "Remote file [#{remote_file}] already exists on HyperV Host and will be re-used" if status
          remote_file = File.join("e:\\",'veewee',iso_file ).gsub('/', '\\')
          env.ui.info "Mounting cdrom: #{remote_file}"
          powershell_exec "Set-VMDvdDrive -VMName #{name} -Path '#{remote_file}' -ControllerNumber #{device_number} -ControllerLocation #{port}" if port == 0
          powershell_exec "Add-VMDvdDrive -VMName #{name} -Path '#{remote_file}' -ControllerNumber #{device_number} -ControllerLocation #{port}" if port == 1
        end

        def detach_isofile(device_number = 0,port = 0)
          env.ui.info "Un-Mounting cdrom on controller #{device_number} and port #{port}"
          powershell_exec "Set-VMDvdDrive -VMName #{name} -ControllerNumber #{device_number} -ControllerLocation #{port} -Path $null"
        end

        def attach_floppy(floppy = 'virtualfloppy.vfd')
          # Attach floppy to machine (the vfd extension is crucial to detect msdos type floppy)
          local_file = File.join(definition.path,"#{floppy}").gsub('/', '\\')
          remote_file = File.join("\\\\",definition.hyperv_host,'veewee',"#{floppy}").gsub('/', '\\')
          env.ui.info "Copying VirtualFloppy file [#{local_file}] to HyperV Host"
          powershell_exec "Copy-Item -Path '#{local_file}' -Destination '#{remote_file}'",{:remote => false}
          remote_file = File.join("e:\\",'veewee',"#{floppy}").gsub('/', '\\')
          env.ui.info "Mounting VirutalFloppy: #{remote_file}"
          powershell_exec("Set-VMFloppyDiskDrive -VMName #{name} -Path '#{remote_file}'")
        end

        def detach_floppy
          env.ui.info "Un-Mounting floppy"
          powershell_exec("Set-VMFloppyDiskDrive -VMName #{name} -Path $null")
        end

      end
    end
  end
end