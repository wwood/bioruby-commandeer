require 'systemu'

module Bio
  # See #run
  class Commandeer

    # Run a command line program, and be opinionated about how to handle failure
    #
    # command is a string of the command to be run
    # * options is a hash, with keys:
    # :stdin: a string that is the stdin
    # :log: if true, turn on logging. If given an object use it as the logger
    def self.run(command, options={})
      if options[:log]
        if options[:log] == true
          log_name = 'bio-commandeer'
          @log = Bio::Log::LoggerPlus[log_name]
          if @log.nil? or @log.outputters.empty?
            @log = Bio::Log::LoggerPlus.new(log_name)
            Bio::Log::CLI.configure(log_name)
          end
        else
          @log = options[:log]
        end

        @log.info "Running command: #{command}"
      end
      status, stdout, stderr = systemu command, :stdin => options[:stdin]

      if @log
        @log.info "Command finished with exitstatus #{status.exitstatus}"
      end

      if status.exitstatus != 0
        raise Bio::CommandFailedException, "Command returned non-zero exit status (#{status.exitstatus}), likely indicating failure. Command run was #{command} and the STDERR was:\n#{stderr}"
      end

      return stdout
    end
  end

  class CommandFailedException < Exception; end
end
