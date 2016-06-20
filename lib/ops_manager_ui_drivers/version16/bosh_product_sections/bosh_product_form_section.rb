module OpsManagerUiDrivers
  module Version16
    module BoshProductSections
      class BoshProductFormSection
        def initialize(browser, field_prefix)
          @browser = browser
          @field_prefix = field_prefix
        end

        def open_form(form_name)
          @browser.visit '/'
          @browser.click_on 'show-p-bosh-configure-action'
          @browser.click_on "show-#{form_name}-action"
        end

        def save_form(allowed_errors=[])
          @browser.click_on 'Save'
          !@browser.all('.flash-message.success').empty? || only_has_allowed_verification_errors(allowed_errors)
        end

        def set_fields(fields)
          fields.each do |field, value|
            set_field(field, value)
          end
        end

        private

        def only_has_allowed_verification_errors(allowed_errors)
          flash_errors = @browser.all('.flash-message.error')
          unexpected_errors = []

          if flash_errors.any?
            unexpected_errors = flash_errors.reject do |error|
              allowed_errors.select do |expected_error|
                error.text =~ expected_error
              end.any?
            end
          end

          unexpected_errors.empty?
        end

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
