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
      obj = run_to_finish(command, options)

      if obj.status.exitstatus != 0
        raise Bio::CommandFailedException, "Command returned non-zero exit status (#{obj.status.exitstatus}), likely indicating failure. Command run was #{command} and the STDERR was:\n#{obj.stderr}\nSTDOUT was: #{obj.stdout}"
      end

      return obj.stdout
    end

    # Options are as per #run, but return a CommandResult object
    def self.run_to_finish(command, options={})
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
      res = CommandResult.new
      res.command = command
      res.status, res.stdout, res.stderr = systemu command, :stdin => options[:stdin]

      if @log
        @log.info "Command finished with exitstatus #{res.status.exitstatus}"
      end
      return res
    end
  end

  class CommandResult
    attr_accessor :stdout, :stderr, :command, :status
  end

  class CommandFailedException < Exception; end
end
