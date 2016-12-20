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

    def om_1_7(ops_manager_url, browser = self)
      @om_1_7 ||= create_web_ui(
        ops_manager_url: ops_manager_url,
        browser: browser,
        version_module: Version17,
      )
    end

    def om_1_8(ops_manager_url, browser = self)
      @om_1_8 ||= create_web_ui(
        ops_manager_url: ops_manager_url,
        browser: browser,
        version_module: Version18,
      )
    end

    def om_1_9(ops_manager_url, browser = self)
      @om_1_9 ||= create_web_ui(
        ops_manager_url: ops_manager_url,
        browser: browser,
        version_module: Version19,
      )
    end

    def om_1_10(ops_manager_url, browser = self)
      @om_1_10 ||= create_web_ui(
        ops_manager_url: ops_manager_url,
        browser: browser,
        version_module: Version110,
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

    def api_1_7(host:, username:, password:)
      Version17::Api.new(host_uri: host, username: username, password: password)
    end

    def api_1_8(host:, username:, password:)
      Version18::Api.new(host_uri: host, username: username, password: password)
    end

    def api_1_9(host:, username:, password:)
      Version19::Api.new(host_uri: host, username: username, password: password)
    end

    def api_1_10(host:, username:, password:)
      Version110::Api.new(host_uri: host, username: username, password: password)
    end

    alias_method :om_rc, :om_1_10
    alias_method :api_rc, :api_1_10

    private

    def create_web_ui(ops_manager_url:, browser:, version_module:)
      Capybara.app_host = ops_manager_url
      Logger.debug "Creating Ops Manager UI Driver for #{version_module.inspect}"
      version_module::WebUi.new(browser: browser)
    end
  end
end
