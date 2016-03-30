require 'ops_manager_ui_drivers/version16/product_dashboard'
require 'ops_manager_ui_drivers/animation_helper'

module OpsManagerUiDrivers
  module Version17
    class ProductDashboard < Version16::ProductDashboard
      include AnimationHelper

      def import_installation_file(_file_path)
        fail('Importing is no longer supported via the Product Dashboard. See Version17::Setup#import_installation_file')
      end

      def product_available?(product_name, product_version)
        open_dashboard
        browser.all("li.#{product_name} input#product_version[value='#{product_version}']", {visible: false}).any?
      end

      def delete_product(product_name)
        open_dashboard
        disable_css_transitions!
        browser.click_on "open-delete-#{product_name}-modal"
        browser.click_on "delete-#{product_name}-action"
      end

      def delete_unused_products
        open_dashboard
        @browser.find('a#delete_unused_products').trigger('click')
      end

      def deleted_product?(product_name)
        open_dashboard
        browser.first("#show-#{product_name}-information-action").present?
      end

      def apply_updates(validate: true, errands: {})
        open_dashboard
        check_errands(errands)

        browser.click_on 'install-action'
        if validate
          fail 'Install failed verification' if nonignorable_verification_failed?
          allow_cpu_verification_errors
          allow_privilege_verification_errors
          allow_icmp_verification_errors #this is only for AWS; consider moving out

          ignore_allowable_errors
          assert_installation_started
        end

        ApplyUpdatesResult.new(browser: @browser)
      end

      def enabled_errands(product_name)
        open_dashboard
        browser.execute_script "$('li.expandable > a.title').click()"
        browser.all("input[type='checkbox'][name^='enabled_errands[#{product_name}-'][checked='checked']").map do |checkbox|
          checkbox.value
        end
      end

      def most_recent_install_log
        browser.visit '/change_log'
        sleep 4
        first_log_entry = browser.first('table#change-log tbody tr td a')
        if first_log_entry
          base_url = first_log_entry[:href]
          browser.visit "#{base_url}.text"
          browser.source
        else
          return nil
        end
      end

      private

      def check_errands(errands)
        browser.execute_script "$('li.expandable > a.title').click()"

        errands.each do |product_name, errand_types|
          errand_types.each do |_errand_type, errand_selections|
            errand_selections.each do |identifier, enabled|
              browser.execute_script "$('input[type=checkbox][name^=\"enabled_errands[#{product_name}-\"][value=\"#{identifier}\"]').prop('checked', #{enabled.to_json})"
            end
          end
        end
      end
    end
  end
end
