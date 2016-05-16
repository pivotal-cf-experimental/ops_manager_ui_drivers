require 'ops_manager_ui_drivers/version17/api'
require 'uaa'
require 'net/http/post/multipart'

module OpsManagerUiDrivers
  module Version18
    class Api < Version17::Api
      SETUP_PATH = 'api/v0/setup'
      PRODUCTS_PATH = 'api/v0/staged/products'
      PRODUCTS_UPLOAD_PATH = 'api/v0/available_products'
      STEMCELLS_UPLOAD_PATH = 'api/v0/stemcells'
      NETWORKS_AND_AZS_PATH = PRODUCTS_PATH + '/:product_id/networks_and_azs'


      def internal_setup!
        setup_params = {
          eula_accepted: 'true',
          admin_user_name: @username,
          admin_password: @password,
          admin_password_confirmation: @password,
          decryption_passphrase: @password,
          decryption_passphrase_confirmation: @password,
          identity_provider: 'internal',
        }

        post_request(endpoint: SETUP_PATH, params: setup_params)
      end

      def add_product!(name:, product_version:)
        params = {
          name: name,
          product_version: product_version
        }

        post_request(endpoint: PRODUCTS_PATH, params: params)
      end

      def upload_product_zip(path:)
        post_file(
          endpoint: PRODUCTS_UPLOAD_PATH,
          path: path,
          type: 'application/zip') do |file_param|
          {
            'product' => {
              'file' => file_param
            }
          }
        end
      end

      def upload_stemcell(path:)
        post_file(
          endpoint: STEMCELLS_UPLOAD_PATH,
          path: path,
          type: 'application/zip') do |file_param|
          {
            'stemcell' => {
              'file' => file_param
            }
          }
        end
      end

      def assign_azs_and_network(product_guid:, singleton_availability_zone:, availability_zones:, network:, service_network: nil)
        params = {
          networks_and_azs: {
            singleton_availability_zone: { name: singleton_availability_zone },
            other_availability_zones: availability_zones.map{|az| { name: az } },
            network: { name: network },
          }
        }

        params[:networks_and_azs].merge!(service_network: { name: service_network }) if service_network

        endpoint = url_for_product(product_id: product_guid, route: NETWORKS_AND_AZS_PATH)
        put_request(endpoint: endpoint, params: params)
      end

      def product_guid(product_name:)
        response = get_request(endpoint: PRODUCTS_PATH)

        JSON.parse(response.body).find {|product_hash| product_hash['type'] == product_name }['guid']
      end

      private

      def url_for_product(product_id:, route:)
        route.gsub(':product_id', product_id)
      end

      def post_file(endpoint:, path:, type:)
        conn = faraday_connection { |faraday |faraday.request :multipart }
        body = yield(Faraday::UploadIO.new(path, type))

        faraday_request(method: :post, conn: conn, body: body, endpoint: endpoint)
      end

      def get_request(endpoint:)
        faraday_request(method: :get, endpoint: endpoint)
      end

      def post_request(endpoint:, params:)
        json_body = params.to_json

        faraday_request(method: :post, body: json_body, endpoint: endpoint) do |req|
          req.headers['Content-Type'] = 'application/json'
        end
      end

      def put_request(endpoint:, params:)
        json_body = params.to_json

        faraday_request(method: :put, body: json_body, endpoint: endpoint) do |req|
          req.headers['Content-Type'] = 'application/json'
        end
      end

      def faraday_request(conn: faraday_connection, endpoint:, body: nil, method: )
        conn.send(method) do |req|
          yield(req) if block_given?
          req.body = body if body
          req.url(endpoint)
          req.headers['Authorization'] = uaa_token.auth_header
        end
      end

      def faraday_connection
        Faraday.new(:url => @host_uri) do |faraday|
          yield(faraday) if block_given?
          faraday.adapter :net_http
        end
      end

    end
  end
end
