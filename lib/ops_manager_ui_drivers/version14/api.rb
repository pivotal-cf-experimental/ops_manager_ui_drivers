require 'net/https'

module OpsManagerUiDrivers
  module Version14
    class Api
      def initialize(host: nil, user: nil, password: nil)
        @host = host
        @user = user
        @password = password
      end

      def export_installation
        tmpfile = Tempfile.new('installation.zip')
        http.request(get('installation_asset_collection')) do |response|
          response.read_body do |chunk|
            tmpfile.write(chunk)
          end
        end
        tmpfile.close
        tmpfile
      end

      private

      def http
        uri = URI(@host)
        Net::HTTP.new(uri.host, uri.port).tap do |http|
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.read_timeout = 1800
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
