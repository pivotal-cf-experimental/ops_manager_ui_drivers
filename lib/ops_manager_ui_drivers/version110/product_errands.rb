require 'ops_manager_ui_drivers/version19/product_errands'

module OpsManagerUiDrivers
  module Version110
    class ProductErrands < Version19::ProductErrands
      def enable_errand(errand_name)
        open_form
        set_check_box("errands[#{errand_name}][run_errand_pre_delete]", true)
        set_check_box("errands[#{errand_name}][run_errand_post_deploy]", true)
        save_form
      end

      def disable_errand(errand_name)
        open_form
        set_check_box("errands[#{errand_name}][run_errand_pre_delete]", false)
        set_check_box("errands[#{errand_name}][run_errand_post_deploy]", false)
        save_form
      end

      def enabled_errands
        open_form

        result = []

        browser.all("input[type='checkbox'][name^='errands['][name$='][run_errand_post_deploy]'][checked='checked']").map do |checkbox|
          errand_name = checkbox[:name].match(/errands\[(.*)\]\[run_errand_post_deploy\]/)[1]
          result << errand_name
        end

        browser.all("input[type='checkbox'][name^='errands['][name$='][run_errand_pre_delete]'][checked='checked']").map do |checkbox|
          errand_name = checkbox[:name].match(/errands\[(.*)\]\[run_errand_pre_delete\]/)[1]
          result << errand_name
        end

        result
      end

      private

      def set_check_box(name, value)
        check_box = browser.first(:css, %Q(input[type="checkbox"][name="#{name}"]))
        check_box.set(value) if check_box
      end
    end
  end
end
