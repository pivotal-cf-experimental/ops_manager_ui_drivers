require 'ops_manager_ui_drivers/version19/product_dashboard'

module OpsManagerUiDrivers
  module Version110
    class ProductDashboard < Version19::ProductDashboard
      def apply_updates(validate: true, errands: {})
        open_dashboard
        select_errand_states(errands)

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

      def errands_with_state(product_name, errand_state)
        option_value = translate_errand_state(errand_state)
        open_dashboard
        browser.execute_script "$('li.expandable > a.title').click()"
        browser.all("[ name ^= 'errands[#{product_name}-' ]").
          select { |select| select[:value] == option_value }.
          map { |select| select[:name].match(/^errands\[.*\]\[run_(?:post_deploy|pre_delete)\]\[(.*)\]$/)[1]}
      end

      private

      def translate_errand_state(errand_state)
        case errand_state
          when 'On'
            'true'
          when 'Off'
            'false'
          when 'When Changed'
            'when-changed'
          else
            raise "Unknown errand state: #{errand_state.inspect}"
        end
      end

      def select_errand_states(errands)
        browser.execute_script "$('li.expandable > a.title').click()"

        errands.each do |product_name, errand_types|
          errand_types.each do |errand_type, errand_selections|
            errand_selections.each do |errand_identifier, errand_run_state|

              state_map = {
                true => 0,
                false => 1,
                'when-changed' => 2,
              }

              browser.execute_script(
                <<-JS
                  $(
                      '[ name ^= "errands[#{product_name}-" ]' +
                      '[ name *= "][#{errand_type}" ]' +
                      '[ name $= "][#{errand_identifier}]" ]'
                   ).prop('selectedIndex', #{state_map[errand_run_state]})
              JS
              )
            end
          end
        end
      end
    end
  end
end
