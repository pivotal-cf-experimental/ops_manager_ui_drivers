module OpsManagerUiDrivers
  module Version17
    module BoshProductSections
      class BoshProductFormSection
        attr_reader :field_prefix

        def initialize(browser, field_prefix)
          @browser = browser
          @field_prefix = field_prefix
        end

        def open_form(form_name)
          @browser.visit '/'
          @browser.click_on 'show-p-bosh-configure-action'
          @browser.click_on "show-#{form_name}-action"
        end

        def save_form
          @browser.click_on 'Save'
          @browser.expect(@browser.page).to @browser.have_css('.flash-message.success')
        end

        def set_fields(fields)
          fields.each do |field, value|
            if value.is_a? Hash
              handle_customized_field_value(value)
            else
              set_field(field, value)
            end
          end
        end

        def select_all_az_references_on_page
          @browser.all(:field, "#{@field_prefix}[availability_zone_references][]").each do |node|
            node.set(true)
          end
        end

        private

        def handle_customized_field_value(value)
          @browser.send(value['browser_command'], value['browser_arg'])
        end

        def set_field(field, value)
          last_field(field).set(value)
        end

        def last_field(field)
          name = "#{@field_prefix}[#{field}]"
          @browser.execute_script "$('a[data-masked-input-name=\"#{name}\"]:contains(\"Change\")').click()"
          @browser.all(:field, name, minimum: 1).last
        end
      end
    end
  end
end
