require 'ops_manager_ui_drivers/version17/ops_manager_director'
using OpsManagerUiDrivers::BackportRefinements

module OpsManagerUiDrivers
  module Version18
    class OpsManagerDirector < Version17::OpsManagerDirector
      def initialize(browser:, iaas_configuration: Version18::BoshProductSections::IaasConfiguration.new(browser: browser))
        @browser = browser
        @iaas_configuration = iaas_configuration
      end

      def configure_iaas(test_settings)
        iaas_settings = Settings.for(test_settings)
        iaas_specific_fields = iaas_settings.iaas_configuration_fields
        advanced_infrastructure_config_fields = iaas_settings.advanced_infrastructure_config_fields
        iaas_configuration.fill_iaas_settings(iaas_specific_fields)
        advanced_infrastructure_config.fill_advanced_infrastructure_config_settings(advanced_infrastructure_config_fields)
      end

      def config_director(ops_manager)
        browser.visit '/'
        browser.click_on 'show-p-bosh-configure-action'

        browser.click_on 'show-director_configuration-action'


        browser.fill_in('director_configuration[ntp_servers_string]', with: ops_manager.dig('ntp_servers'))
        browser.check('Enable VM Resurrector Plugin') if ops_manager.dig('resurrector_enabled')

        s3_blobstore = ops_manager.dig('s3_blobstore')
        if s3_blobstore
          browser.choose('S3 Compatible Blobstore')
          browser.fill_in('director_configuration[s3_blobstore_options][endpoint]', with: s3_blobstore.dig('endpoint'))
          browser.fill_in('director_configuration[s3_blobstore_options][bucket_name]', with: s3_blobstore.dig('bucket_name'))
          browser.fill_in('director_configuration[s3_blobstore_options][access_key]', with: s3_blobstore.dig('access_key_id'))
          @browser.execute_script "$('a[data-masked-input-name=\"director_configuration[s3_blobstore_options][secret_key]\"]:contains(\"Change\")').click()"
          browser.fill_in('director_configuration[s3_blobstore_options][secret_key]', with: s3_blobstore.dig('secret_access_key'))

          signature_version = s3_blobstore.dig('signature_version')
          if signature_version == 4
            browser.choose('V4 Signature')
            browser.fill_in('director_configuration[s3_blobstore_options][region]', with: s3_blobstore.dig('region'))
          end
        end

        mysql = ops_manager.dig('mysql')
        if mysql
          browser.choose('External MySQL Database')
          browser.fill_in('director_configuration[external_database_options][host]', with: mysql.dig('host'))
          browser.fill_in('director_configuration[external_database_options][port]', with: mysql.dig('port'))
          browser.fill_in('director_configuration[external_database_options][user]', with: mysql.dig('user'))
          @browser.execute_script "$('a[data-masked-input-name=\"director_configuration[external_database_options][password]\"]:contains(\"Change\")').click()"
          browser.fill_in('director_configuration[external_database_options][password]', with: mysql.dig('password'))
          browser.fill_in('director_configuration[external_database_options][database]', with: mysql.dig('dbname'))
        end

        save_form
      end

      def configure_compilation_resources(instances:, vm_type:)
        browser.visit '/'
        browser.click_on 'show-p-bosh-configure-action'

        browser.click_on 'show-p-bosh-resource-sizes-action'

        browser.find("select[name='product_resources_form[compilation][instances]']").
          find("option[value='#{instances}']").
          select_option

        browser.find("select[name='product_resources_form[compilation][vm_type_id]']").
          find("option[value='#{vm_type}']").
          select_option

        save_form
      end

      def save_form(validate: true)
        browser.click_on 'Save'

        fail('unexpected failure') unless browser.has_css?('.flash-message')

        if validate
          fail(browser.find('.flash-message.error').text) unless browser.has_css?('.flash-message.success')
        end
      end

      def advanced_infrastructure_config
        @advanced_infrastructure_config ||= Version18::BoshProductSections::AdvancedInfrastructureConfig.new(browser: browser)
      end

      def availability_zones
        @availability_zones ||= Version18::BoshProductSections::AvailabilityZones.new(browser: browser)
      end

      def networks
        @networks ||= Version18::BoshProductSections::Networks.new(browser: browser)
      end
    end
  end
end
