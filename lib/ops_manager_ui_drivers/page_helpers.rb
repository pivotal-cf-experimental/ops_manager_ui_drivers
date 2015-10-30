require 'ops_manager_ui_drivers/wait_helper'

module OpsManagerUiDrivers
  module PageHelpers
    include OpsManagerUiDrivers::WaitHelper

    def om_1_4(ops_manager_url, browser = self)
      @om_1_4 ||= create_web_ui(
        ops_manager_url: ops_manager_url,
        browser: browser,
        version_module: Version14,
      )
    end

    def om_1_5(ops_manager_url, browser = self)
      @om_1_5 ||= create_web_ui(
        ops_manager_url: ops_manager_url,
        browser: browser,
        version_module: Version15,
      )
    end

    def om_1_6(ops_manager_url, browser = self)
      @om_1_6 ||= create_web_ui(
        ops_manager_url: ops_manager_url,
        browser: browser,
        version_module: Version16,
      )
    end

    def om_rc(ops_manager_url, browser = self)
      @om_1_7 ||= create_web_ui(
        ops_manager_url: ops_manager_url,
        browser: browser,
        version_module: Version17,
      )
    end

    def api_1_4(host:, username:, password:)
      Version14::Api.new(host_uri: host, username: username, password: password)
    end

    def api_1_5(host:, username:, password:)
      Version15::Api.new(host_uri: host, username: username, password: password)
    end

    def api_1_6(host:, username:, password:)
      Version16::Api.new(host_uri: host, username: username, password: password)
    end

    def api_rc(host:, username:, password:)
      Version17::Api.new(host_uri: host, username: username, password: password)
    end

    private

    def create_web_ui(ops_manager_url:, browser:, version_module:)
      Capybara.app_host = ops_manager_url
      puts "Preparing to interact with #{version_module.inspect} at #{Capybara.app_host}"
      version_module::WebUi.new(browser: browser)
    end
  end
end
