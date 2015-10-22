require 'ops_manager_ui_drivers/version16/api'

module OpsManagerUiDrivers
  module Version17
    class Api < Version16::Api
      def set_feature_flag(flag_name, value)
        feature_flag_path = File.join('feature_flags', flag_name)

        http.request(put(feature_flag_path, enabled: value))
      end

      private

      def put(endpoint, form_data)
        Net::HTTP::Put.new(api_uri(endpoint).request_uri).tap do |put_request|
          put_request.basic_auth(@username, @password)
          put_request.set_form_data(form_data)
        end
      end
    end
  end
end
