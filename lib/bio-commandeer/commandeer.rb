require 'systemu'

module Bio
  # See #run
  class Commandeer
    include Bio::CommandeerLogging

    # Run a command line program, and be opinionated about how to handle failure
    #
    # command is a string of the command to be run
    # * options is a hash, with keys:
    # :stdin: a string that is the stdin
    # :log: turn on logging
    def self.run(command, options={})
      if options[:log]
        log_name = 'bio-commandeer'
        @log = Bio::Log::LoggerPlus[log_name]
        if @log.nil? or @log.outputters.empty?
          @log = Bio::Log::LoggerPlus.new(log_name)
          Bio::Log::CLI.configure(log_name)
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
