module OpsManagerUiDrivers
  module Version15
    module MicroboshSections
      class MicroboshFormSection
        def initialize(browser, field_prefix)
          @browser      = browser
          @field_prefix = field_prefix
        end

        def open_form(form_name)
          @browser.visit '/'
          @browser.click_on 'show-microbosh-configure-action'
          @browser.click_on "show-#{form_name}-action"
        end

        def save_form
          @browser.click_on 'Save'
          @browser.expect(@browser.page).to @browser.have_css('.flash-message.success')
        end

        def set_fields(fields)
          fields.each do |field, value|
            set_field(field, value)
          end
        end

        private

        def set_field(field, value)
          last_field(field).set(value)
        end

        def last_field(field)
          @browser.all(:field, "#{@field_prefix}[#{field}]").last
        end
      end
    end
  end
end
