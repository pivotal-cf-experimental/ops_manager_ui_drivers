module OpsManagerUiDrivers
  module Version13
    class ProductDashboard
      def initialize(browser:)
        @browser = browser
        @allowed_ignorable_errors = []
      end

      def apply_updates
        open_dashboard
        browser.click_on 'install-action'
        fail 'Install failed verification' if nonignorable_verification_failed?
        allow_cpu_verification_errors
        allow_privilege_verification_errors

        ignore_allowable_errors
        assert_installation_started
      end

      def import_installation_file(file_path)
        open_dashboard
        browser.click_on 'toggle-installation-dropdown-action'
        browser.click_on 'show-import-backup'
        browser.attach_file 'import[file]', file_path
        browser.click_on 'import-backup'
      end

      def upgrade_microbosh
        open_dashboard
        browser.find('p', text: 'Ops Manager Director').trigger(:mouseover)
        browser.click_on 'upgrade-microbosh'
      end

      def delete_product(product_name)
        open_dashboard
        browser.click_on "open-delete-#{product_name}-modal"
        wait_for_modal_css_transition_to_complete
        browser.click_on "delete-#{product_name}-action"
      end

      def import_product_from(full_path)
        open_dashboard
        browser.attach_file('component_add[file]', full_path, {visible: false})
      end

      def product_available?(product_name, product_version)
        open_dashboard
        browser.all("li.#{product_name} input#component_version[value='#{product_version}']", {visible: false}).any?
      end

      def upgrade_product(product_name)
        open_dashboard
        browser.find(".product.#{product_name} p").trigger(:mouseover)
        browser.click_on "upgrade-#{product_name}"
        expect_no_flash_errors
      end

      def version_for_product(product_name)
        open_dashboard
        browser.find("#show-#{product_name}-configure-action .version").text
      end

      def delete_whole_installation
        open_dashboard
        browser.click_on 'toggle-installation-dropdown-action'
        browser.click_on 'show-delete-installation-modal-action'
        wait_for_modal_css_transition_to_complete
        browser.click_on 'delete-installation-action'
      end

      def delete_installation_available?
        open_dashboard
        browser.click_on 'toggle-installation-dropdown-action'
        browser.all('#show-delete-installation-modal-action').any?
      end

      def deletion_in_progress?
        open_dashboard
        browser.all('#delete-in-progress-marker').any?
      end

      def reset_state
        revert_pending_changes if revert_available?
        delete_whole_installation if delete_installation_available?
      end

      private

      attr_reader :browser

      def assert_installation_started
        browser.expect(browser.page).to browser.have_text('Installation in Progress')
      end

      def nonignorable_verification_failed?
        browser.all('.flash-message.error').any? && browser.all('#ignore-install-action').empty?
      end

      def allow_cpu_verification_errors
        cpu_verification_regex = /Installation requires \d+ CPU cores/
        return if @allowed_ignorable_errors.include?(cpu_verification_regex)

        @allowed_ignorable_errors << cpu_verification_regex
      end

      def allow_privilege_verification_errors
        priveleges_regex = /privileges are required/i
        return if @allowed_ignorable_errors.include?(priveleges_regex)

        @allowed_ignorable_errors << priveleges_regex
      end

      def ignore_allowable_errors
        flash_errors = browser.all('.flash-message.error')

        if flash_errors.any?
          unexpected_errors = flash_errors.reject do |error|
            @allowed_ignorable_errors.select do |expected_error|
              error.text =~ expected_error
            end.any?
          end

          if unexpected_errors.empty?
            browser.click_on 'ignore-install-action'
          else
            fail "Unexepcted ignorable errors: #{unexpected_errors.map(&:text).inspect}"
          end
        end
      end

      def expect_no_flash_errors
        if (flash_error = browser.all('.flash-message.error').first)
          fail flash_error.text
        end
      end

      def wait_for_modal_css_transition_to_complete
        sleep 5 # Have to wait for the CSS shade effect
      end

      def open_dashboard
        browser.visit '/'
      end

      def revert_pending_changes
        open_dashboard
        browser.click_on 'open-revert-installation-modal-action'
        wait_for_modal_css_transition_to_complete
        browser.click_on 'revert-installation-action'
      end

      def revert_available?
        browser.all('#open-revert-installation-modal-action').any?
      end
    end
  end
end
