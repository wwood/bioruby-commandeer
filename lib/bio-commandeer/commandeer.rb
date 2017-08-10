require 'systemu'
require 'timeout'

module Bio
  # See #run
  class Commandeer
    # Run a command line program, and be opinionated about how to handle failure
    #
    # command is a string of the command to be run
    # * options is a hash, with keys:
    # :stdin: a string that is the stdin
    # :log: if true, turn on logging. If given an object use it as the logger
    # :timeout: number of seconds to allow the process to run for. If nil (the default),
    #           no timeout.
    def self.run(command, options={})
      obj = run_to_finish(command, options)
      obj.raise_if_failed

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
      begin
        Timeout::timeout(options[:timeout]) do
          res.status, res.stdout, res.stderr = systemu command, :stdin => options[:stdin]
        end
      rescue Timeout::Error => e
        res.timed_out = true
      end

      if @log
        @log.info "Command finished with exitstatus #{res.status.exitstatus}"
      end
      return res
    end
  end

  class CommandResult
    attr_accessor :stdout, :stderr, :command, :status, :timed_out

    def raise_if_failed
      if @timed_out
        raise Bio::CommandFailedException, "Command timed out. Command run was #{command}."
      elsif @status.exitstatus != 0
        raise Bio::CommandFailedException, "Command returned non-zero exit status (#{@status.exitstatus}), likely indicating failure. Command run was #{@command} and the STDERR was:\n#{@stderr}\nSTDOUT was: #{@stdout}"
      end
    end
  end

  class CommandFailedException < Exception; end
end
