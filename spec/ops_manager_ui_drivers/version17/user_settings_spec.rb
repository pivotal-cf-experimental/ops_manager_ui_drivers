require 'spec_helper'
module OpsManagerUiDrivers
  module Version17
    describe UserSettings do
      let(:browser) { double('browser') }

      describe '#switch_to_internal_authentication' do
        it 'fills in the username and password and waits to be redirected' do
          user_name = 'user'
          user_password = 'password'

          expect(browser).to receive(:visit).with('/settings/edit')
          expect(browser).to receive(:click_on).with('update-auth-service-action')
          expect(browser).to receive(:fill_in).with('change_auth_service[admin_user_name]', with: user_name)
          expect(browser).to receive(:fill_in).with('change_auth_service[admin_password]', with: user_password)
          expect(browser).to receive(:fill_in).with('change_auth_service[admin_password_confirmation]', with: user_password)
          expect_any_instance_of(UserSettings).to receive(:wait_for_availability!)

          UserSettings.new(browser: browser).switch_to_internal_authentication(user: user_name, password: user_password)
        end
      end

      describe '#switch_to_saml_authentication' do
        it 'fills in the idp_metadata and waits to be redirected' do
          idp_metadata = 'some_saml_endpoint'

          expect(browser).to receive(:visit).with('/settings/edit')
          expect(browser).to receive(:click_on).with('update-auth-service-action')
          expect(browser).to receive(:fill_in).with('change_auth_service[saml_idp_metadata]', with: idp_metadata)
          expect_any_instance_of(UserSettings).to receive(:wait_for_availability!)

          UserSettings.new(browser: browser).switch_to_saml_authentication(idp_metadata: idp_metadata)
        end
      end
    end
  end
end
