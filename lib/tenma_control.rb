require 'serialport'
require 'tenma_control/version'

module TenmaControl

  class PSU

    # interframe timeout in ms
    #
    # Tenma uses interframe timeout to determine the end of a frame. 
    # The minimum timeout value isn't published so this is one I figured
    # out by trial and error.
    #
    # You can override this on initialisation using the :timeout param.
    #
    TIMEOUT = 100

    def write(s)
      @port.write(s)
      sleep @timeout/1000.0
    end
    
    def read
      @port.read
    end
    
    private :write, :read

    # Create an instance of PSU and yield to a block
    #
    # @note will close serial port after block 
    #
    # @param dev [String] device string
    # @param opts [Hash]
    #
    # @option opts [Integer] :baud override default (9600) baud 
    # @option opts [Integer] :timeout override default (100ms) interfame timeout (in milliseconds)
    #
    # @return [PSU]
    #
    def self.open(dev, **opts)
      obj = self.new(dev, **opts)
      yield(obj) if block_given?
      obj.close
      obj
    end

    # Create an instance of PSU
    # 
    # @param dev [String] device string
    # @param opts [Hash]
    #
    # @option opts [Integer] :baud override default (9600) baud 
    # @option opts [Integer] :timeout override default (100ms) interfame timeout (in milliseconds)
    #
    def initialize(dev, **opts)      
      @dev = dev
      @port = nil
      @timeout = TIMEOUT||opts[:timeout].to_i
      @port.read_timeout = @timeout            
      open()
    end
    
    # (re-)open the serial port
    def open
      @port = SerialPort.new(@dev, @baud)
    end
    
    # close the serial port
    def close
      @port.close
    end

    # Set current limit
    # 
    # @warning this command does not confirm the setting has been applied
    #
    # @param current [Float] current limit setting to apply
    #
    # @return [self]
    # 
    def set_current(channel=1, current)
      write "ISET#{channel}:#{current.to_f}"       
      self
    end
    
    # Sets and checks current limit.
    #
    # @param current [Float] current limit setting to apply
    # 
    # @return [TrueClass] success
    # @return [FalseClass] failure
    #
    def set_current_confirmed(channel=1, current)
      set_current(channel, current.to_f).get_current_setting(channel) == current 
    end
    
    # Get the current limit setting.
    #
    # @return [Float] current limit setting
    #
    def get_current_setting(channel=1)
      write "ISET#{channel}?"       
      read.to_f
    end
    
    # Get the measured output current.
    #
    # @return [Float] current measurement
    #
    def get_current_output(channel=1)
      write "IOUT#{channel}?"       
      read.to_f
    end
    
    # Set voltage.
    # 
    # @warning this command does not confirm the setting has been applied
    #
    # @param voltage [Float] voltage setting to apply
    #
    # @return [self]
    # 
    def set_voltage(channel=1, voltage)
      write "VSET#{channel}:#{voltage.to_f}"
      self
    end
    
    # Sets and checks voltage.
    #
    # @param current [Float] voltage setting to apply
    # 
    # @return [TrueClass] success
    # @return [FalseClass] failure
    #
    def set_voltage_confirmed(channel=1, voltage)
      set_voltage(channel, voltage.to_f).get_current_setting(channel) == current 
    end

    # Get the voltage setting.
    #
    # @return [Float] voltage setting
    #
    def get_voltage_setting(channel=1)
      write "VSET#{channel}?"       
      read.to_f
    end
    
    # Get the measured output voltage.
    #
    # @return [Float] voltage measurement
    #
    def get_voltage_output(channel=1)
      write "VOUT#{channel}?"       
      read.to_f
    end
    
    # Enable the beep
    #
    # @warning doesn't seem to work
    #
    # @return [self]
    #
    def enable_beep
      write "BEEP1"
      self
    end

    # Disable the beep
    #
    # @warning doesn't seem to work
    #
    # @return [self]
    #    
    def disable_beep
      write "BEEP0"
      self
    end
    
    # Connect output to the load
    #
    # @return [self]
    #
    def enable_output
      write "OUT1"
      self
    end
    
    # Disconnect output from load
    #
    # @return [self]
    #
    def disable_output
      write "OUT0"
      self
    end
    
    # Get the PSU status field.
    #
    # @return [Hash] status_field
    # 
    # @option status_field [Array<TrueClass,FalseClass>] :cc
    # @option status_field [TrueClass,FalseClass] :output_enabled
    #
    def get_status
      write "STATUS?"
      c = read.bytes.first
      {
        :cc => [((c & 0x1) > 0), ((c & 0x2) > 0)],        
        :output_enabled => ((c & 0x40) > 0)
      }      
    end

    # Get the PSU identification string
    #
    # @return [String] identification string
    #
    def get_idn
      write "*IDN?"
      read
    end
    
  end

end
