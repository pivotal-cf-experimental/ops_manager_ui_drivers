require 'ops_manager_ui_drivers/version19/product_errands'

module OpsManagerUiDrivers
  module Version110
    class ProductErrands < Version19::ProductErrands
      def set_errand_state(errand_name, errand_state)
        validate_errand_state(errand_state)
        open_form
        browser.first(:css, %Q(select[name*="#{errand_name}"])).select(errand_state.to_s)
        save_form
      end

      def errands_with_state(errand_state)
        validate_errand_state(errand_state)

        open_form

        result = []

        browser.all("select[ name^='errands[' ][ name*='][run_errand_' ]").map do |errand|
          errand_name = errand[:name].match(/errands\[(.*)\]\[run_errand_.*\]/)[1]
          selected_option = errand.find('option[selected]')
          result << errand_name if selected_option.text == errand_state
        end

        result
      end

      %i(enabled_errands enable_errand disable_errand).each do |method_name|
        define_method(method_name) do
          raise "#{method_name} is deprecated in 1.10 and above"
        end
      end

      private

      def validate_errand_state(errand_state)
        raise "Invalid errand state: #{errand_state.inspect}" unless ['On', 'Off', 'When Changed'].include?(errand_state)
      end
    end
  end
end
