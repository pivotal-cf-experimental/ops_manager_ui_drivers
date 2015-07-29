module OpsManagerUiDrivers
  module Version15
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
        allow_icmp_verification_errors #this is only for AWS; consider moving out

        ignore_allowable_errors
        assert_installation_started
      end

      def import_installation_file(file_path)
        open_dashboard
        browser.click_on 'toggle-installation-dropdown-action'
        browser.click_on 'show-settings'
        browser.click_on 'close-warning'
        browser.attach_file 'import[file]', file_path
        browser.click_on 'import-settings'
        browser.wait { browser.has_text?('Successfully imported installation.') }
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

      def product_on_dashboard?(product_name)
        open_dashboard
        browser.all("a#show-#{product_name}-configure-action").any?
      end

      def import_product_from(full_path)
        open_dashboard
        browser.attach_file('component_add[file]', full_path, {visible: false})
      end

      def product_available?(product_name, product_version)
        open_dashboard
        browser.all("li.#{product_name} input#component_version[value='#{product_version}']", {visible: false}).any?
      end

      def product_complete?(product_name)
        open_dashboard
        browser.all("a#show-#{product_name}-configure-action[data-progress='100']").any?
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
        apply_updates
      end

      def wait_for_installation_to_be_deleted
        browser.poll_up_to_mins(10) do
          open_dashboard
          assert_install_action_disabled
        end
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

      def reset_state(ops_manager)
        revert_pending_changes if revert_available?
        if delete_installation_available?
          delete_whole_installation
          browser.poll_up_to_mins(15) do
            browser.expect(ops_manager.state_change_progress).to browser.be_state_change_success
          end
        end
      end

      def most_recent_install_log
        open_dashboard
        if browser.all('#installation-logs li a', visible: false).any?
          base_url = browser.first('#installation-logs li a', visible: false)[:href]
          browser.visit "#{base_url}.text"
          browser.source
        end
      end

      def revert_pending_changes
        open_dashboard
        browser.click_on 'open-revert-installation-modal-action'
        wait_for_modal_css_transition_to_complete
        browser.click_on 'revert-installation-action'
      end

      def revert_available?
        open_dashboard
        browser.all('#open-revert-installation-modal-action').any?
      end

      private

      attr_reader :browser

      def assert_install_action_disabled
        browser.expect(browser.page).to browser.have_css('#install-action.disabled')
      end

      def assert_installation_started
        browser.expect(browser.page).to browser.have_text('Applying Changes')
      end

      def nonignorable_verification_failed?
        browser.all('.flash-message.error').any? && browser.all('#ignore-install-action').empty?
      end

      def allow_cpu_verification_errors
        return if @allowed_ignorable_errors.include?(/Installation requires \d+ CPU cores/)

        @allowed_ignorable_errors << /Installation requires \d+ CPU cores/
      end

      def allow_privilege_verification_errors
        return if @allowed_ignorable_errors.include?(/required privileges/i)

        @allowed_ignorable_errors << /required privileges/i
      end

      def allow_icmp_verification_errors
        return if @allowed_ignorable_errors.include?(/ignorable if ICMP is disabled/i)

        @allowed_ignorable_errors << /ignorable if ICMP is disabled/i
      end

      def ignore_allowable_errors
        flash_errors = browser.all('.flash-message.error')

        if flash_errors.any?
          unexpected_errors = flash_errors.reject do |error|
            @allowed_ignorable_errors.select do |expected_error|
              error.text =~ expected_error
            end.any?
          end

          browser.click_on 'ignore-install-action' if unexpected_errors.empty?
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
    end
  end
end
