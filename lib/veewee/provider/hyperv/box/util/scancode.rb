module Veewee
  module Provider
    module Hyperv
      module Helper
        class Scancode

          #http://msdn.microsoft.com/en-us/library/dd375731(v=vs.85).aspx

          #TODO: add other keycodes

          @@special_keys = Hash.new
          @@special_keys['<Enter>'] = '0x0D'
          @@special_keys['<Tab>'] = '0x09'

          def self.string_to_keycode(s)
            @@special_keys.keys.each { |key|
              return @@special_keys[key] if s.start_with?(key)
            }
            return s
          end

        end #Class
      end #Module
    end #Module
  end #Module
end #Module
