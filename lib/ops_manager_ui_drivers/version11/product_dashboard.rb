module OpsManagerUiDrivers
  module Version11
    class ProductDashboard
      def initialize(browser:)
        @browser = browser
      end

      def apply_updates
        open_dashboard
        browser.click_on 'install-action'
        browser.fail('Install failed verification') if nonignorable_verification_failed?
        ignore_cpu_verification
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

      def nonignorable_verification_failed?
        browser.all('.flash-message.error').any? && browser.all('#ignore-install-action').empty?
      end

      def ignore_cpu_verification
        if (flash_error = browser.all('.flash-message.error').first)
          browser.click_on 'ignore-install-action' if flash_error.text =~ /Installation requires \d+ CPU cores/
        end
      end

      def wait_for_modal_css_transition_to_complete
        sleep 2 # :(
      end

      def open_dashboard
        browser.visit '/'
      end

      def revert_available?
        browser.all('#open-revert-installation-modal-action').any?
      end

      def revert_pending_changes
        open_dashboard
        browser.click_on 'open-revert-installation-modal-action'
        wait_for_modal_css_transition_to_complete
        browser.click_on 'revert-installation-action'
      end
    end
  end
end
