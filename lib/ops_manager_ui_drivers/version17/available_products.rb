require 'ops_manager_ui_drivers/wait_helper'
require 'ops_manager_ui_drivers/animation_helper'

module OpsManagerUiDrivers
  module Version17
    class AvailableProducts
      include AnimationHelper

      def initialize(browser:)
        @browser = browser
      end

      def add_product_to_install(product_name)
        browser.visit '/'
        disable_css_transitions!
        browser.find("ul.product-list li.#{product_name}.product").hover
        browser.click_on "add-#{product_name}"
        browser.find("#show-#{product_name}-configure-action")
      end

      def product_added?(product_name)
        browser.visit '/'
        browser.all("#show-#{product_name}-configure-action").any?
      end

      private

      attr_reader :browser
    end
  end
end
