

require 'bio-logger'
Bio::Log::LoggerPlus.new('bio-commandeer')
module Bio
  module CommandeerLogging
    def log
      Bio::Log::LoggerPlus['bio-commandeer']
    end
  end
end


require 'bio-commandeer/commandeer.rb'
