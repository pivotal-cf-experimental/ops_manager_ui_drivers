require 'net/https'

module OpsManagerUiDrivers
  module Version14
    class Api
      def initialize(host_uri:, username:, password:)
        @host_uri = URI.parse(host_uri) # we expect "proto://host(:port)"
        @username = username
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
        Net::HTTP.new(@host_uri.host, @host_uri.port).tap do |http|
          http.use_ssl = @host_uri.is_a?(URI::HTTPS)
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.read_timeout = 1800
        end
      end

      def get(endpoint)
        Net::HTTP::Get.new(api_uri(endpoint).request_uri).tap do |get|
          get.basic_auth(@username, @password)
        end
      end

      def api_uri(endpoint)
        URI.parse(
          URI.join(@host_uri.to_s, File.join('api', endpoint)).to_s
        )
      end
    end
  end
end
