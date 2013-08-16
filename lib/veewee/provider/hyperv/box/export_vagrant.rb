require 'pathname'
require 'erb'
module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        class ErbBinding < OpenStruct
          def get_binding
            return binding()
          end
        end

        #    Shellutil.execute("vagrant package --base #{vmname} --include /tmp/Vagrantfile --output /tmp/#{vmname}.box", {:progress => "on"})

        def export_vagrant(options)

          # Check if box already exists
          unless self.exists?
            ui.info "VM #{name} does not exist"
            exit
          end

          # We need to shutdown first
          if self.running?
            self.halt

            #Wait for state poweroff
            while (self.running?) do
              ui.info ".",{:new_line => false}
              sleep 1
            end
            ui.info ""
            ui.info "Machine #{name} is powered off cleanly"
          end

          boxdir = "E:\\veewee\\export\\#{name}" #TODO: This is a hack to work around HyperV network access
          powershell_exec "if (Test-Path -Path #{boxdir}) {exit} ; New-Item -Path #{boxdir} -Itemtype directory"

          #Vagrant requires a relative path for output of boxes
          full_path=File.join(boxdir,name+".box").gsub('/', '\\')
          path1=Pathname.new(full_path)
          path2=Pathname.new(Dir.pwd)
          #box_path=File.expand_path(path1.relative_path_from(path2).to_s)
          box_path=full_path

          result = powershell_exec "Test-Path -Path #{box_path}"
          raise Veewee::Error, "box #{name}.box already exists, provide --force to override" if result.stdout == true && options['force'].nil?

          # Create temp directory
          ui.info "Creating a temporary directory for export"

          tmp_dir = File.join(boxdir,'temp').gsub('/', '\\')
          powershell_exec "if (Test-Path -Path #{tmp_dir}) {exit} ; New-Item -Path #{tmp_dir} -Itemtype directory"

          env.logger.debug("Create temporary directory for export #{tmp_dir}")
          env.ui.info("Create temporary directory for export #{tmp_dir}")

          begin

            ui.info "Adding additional files"

            # Handling the Vagrantfile
            if options["vagrantfile"].to_s == ""

              # Fetching mac address

              data = {
                  :macaddress => get_mac_address
              }

              # Prepare the vagrant erb
              vars = ErbBinding.new(data)
              template_path = File.join(File.dirname(__FILE__),'..','..','..','templates',"Vagrantfile.erb")
              template = File.open(template_path).readlines.join
              erb = ERB.new(template)
              vars_binding = vars.send(:get_binding)
              result = erb.result(vars_binding)
              ui.info("Creating Vagrantfile")
              vagrant_path = "\\\\#{definition.hyperv_host}\\veewee\\export\\#{name}\\temp\\Vagrantfile"
              env.logger.debug("Path: #{vagrant_path}")
              env.logger.debug(result)
              File.open(vagrant_path,'w') {|f| f.write(result) }
            else
              f = options["vagrantfile"]
              env.logger.debug("Including vagrantfile: #{f}")
              FileUtils.cp(f,"\\\\#{definition.hyperv_host}\\veewee\\export\\#{name}\\temp\\Vagrantfile")
            end

            # Handling other includes
            unless options["include"].nil?
              options["include"].each do |f|
                env.logger.debug("Including file: #{f}")
                FileUtils.cp(f,File.join(tmp_dir,f))
              end
            end

            ui.info "Exporting the box"
            powershell_exec("Export-VM -Name #{name} -Path #{tmp_dir}")

            ui.info "Packaging the box"
            powershell_exec "Get-ChildItem -Path #{tmp_dir} -Recurse | Write-Tar -OutputPath #{box_path}"

          rescue Errno::ENOENT => ex
            raise Veewee::Error, "#{ex}"
          rescue Error => ex
            raise Veewee::Error, "Packaging of the box failed:\n+#{ex}"
          ensure
            # Remove temporary directory
            ui.info "Cleaning up temporary directory"
            env.logger.debug("Removing temporary dir #{tmp_dir}")
            powershell_exec "Remove-Item -Path #{tmp_dir} -Recurse" unless options['debug']
          end
          ui.info ""

          #add_ssh_nat_mapping back!!!!
          #vagrant removes the mapping
          #we need to restore it in order to be able to login again
          #self.add_ssh_nat_mapping

          ui.info "To import it into vagrant type:"
          ui.info "vagrant box add '#{name}' '#{box_path}'"
          ui.info ""
          ui.info "To use it:"
          ui.info "vagrant init '#{name}'"
          ui.info "vagrant up"
          ui.info "vagrant ssh"
        end

      end #Module
    end #Module
  end #Module
end #Module
