require 'net/https'

module OpsManagerUiDrivers
  module Version12
    class Api
      def initialize(host: nil, user: nil, password: nil)
        @host = host
        @user = user
        @password = password
      end

      def export_installation
        response = http.request(get('installation_asset_collection'))

        Tempfile.new('installation.zip').tap do |tempfile|
          tempfile.write(response.body)
          tempfile.close
        end
      end

      private

      def http
        uri = URI(@host)
        Net::HTTP.new(uri.host, uri.port).tap do |http|
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.read_timeout = 900
        end
      end

      def get(endpoint)
        uri = URI("#{@host}/api/#{endpoint}")
        Net::HTTP::Get.new(uri.request_uri).tap do |get|
          get.basic_auth(@user, @password)
        end
      end
    end
  end
end
