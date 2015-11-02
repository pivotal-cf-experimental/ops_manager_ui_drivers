module OpsManagerUiDrivers
  module Logger
    def self.logger=(logger)
      @logger = logger
    end

    def self.logger
      @logger ||= ::Logger.new(STDOUT)
    end

    def self.debug(string)
      logger.debug("#{string} app_host => #{Capybara.app_host}")
    end
  end
end
