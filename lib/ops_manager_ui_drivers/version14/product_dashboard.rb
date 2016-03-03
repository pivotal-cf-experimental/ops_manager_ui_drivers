module OpsManagerUiDrivers
  module Version14
    class ProductDashboard

      def initialize(browser:)
        @browser = browser
        @allowed_ignorable_errors = []
      end

      def apply_updates(validate: true)
        open_dashboard
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
        browser.click_on "open-delete-#{product_name.dasherize}-modal"
        wait_for_modal_css_transition_to_complete
        browser.click_on "delete-#{product_name.dasherize}-action"
      end

      def import_product_from(full_path)
        open_dashboard
        browser.attach_file('component_add[file]', full_path, {visible: false})

        browser.expect(browser.page).to browser.have_text('Successfully added product')
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

      def product_configuration_percentage(product_name)
        open_dashboard
        browser.find("#show-#{product_name}-configure-action")['data-progress'].to_i
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
        result = browser.all('.flash-message.error').any? && browser.all('#ignore-install-action').empty?
        if result
          Logger.debug 'flash message errors; we expect these to be empty'
          Logger.debug browser.all('.flash-message.error').pretty_print_inspect
          Logger.debug 'ignore install action; we expect there to be one of these'
          Logger.debug browser.all('#ignore-install-action').pretty_print_inspect
        end
        result
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

      class ApplyUpdatesResult
        include WaitHelper

        def initialize(browser:)
          @browser = browser
        end

        def has_ignorable_errors?
          browser.has_button?('Ignore errors and start the install')
        end

        def has_nonignorable_errors?
          browser.has_text?('Stop and fix errors') && !has_ignorable_errors?
        end

        def has_install_issues?(retries: 30)
          wait_for_page_to_have_text 'Install Issues', retries: retries
        end

        def completed_successfully?(retries: 30)
          wait_for_page_to_have_text 'successfully applied', retries: retries
        end

        def wait_for_page_to_have_text(text, retries:)
          poll_up_to_times(retries) { browser.expect(browser.page.text).to browser.include(text) }
        end

        private
        attr_reader :browser
      end
    end
  end
end
