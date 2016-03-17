require 'ops_manager_ui_drivers/version16/api'
require 'uaa'

module OpsManagerUiDrivers
  module Version17
    class Api < Version16::Api
      def set_feature_flag(flag_name, value)
        feature_flag_path = File.join('feature_flags', flag_name)

        http.request(put(feature_flag_path, enabled: value))
      end

      def get_products
        http.request(get('v0/available_products'), uaa_token.auth_header)
      end

      def export_installation
        Tempfile.new('installation.zip').tap do |tmpfile|
          http.request(get('v0/installation_asset_collection', uaa_token.auth_header)) do |response|
            response.read_body do |chunk|
              tmpfile.write(chunk)
            end
          end
          tmpfile.close
        end
      end

      private

      def uaa_token
        target_url = @host_uri.to_s + '/uaa'
        token_issuer = CF::UAA::TokenIssuer.new(target_url, 'opsman', nil, {skip_ssl_validation: true})
        token_issuer.owner_password_grant(@username, @password)
      end

      def get(endpoint, token=nil)
        Net::HTTP::Get.new(api_uri(endpoint).request_uri).tap do |get|
          add_auth_to_request(get, token)
        end
      end

      def put(endpoint, form_data, token=nil)
        Net::HTTP::Put.new(api_uri(endpoint).request_uri).tap do |put_request|
          add_auth_to_request(put_request, token)
          put_request.set_form_data(form_data)
        end
      end

      def add_auth_to_request(request, token)
        if token.present?
          request['Authorization'] = token
        else
          request.basic_auth(@username, @password)
        end
      end
    end
  end
end
