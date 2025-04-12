# frozen_string_literal: true

require 'sinatra/base'
require 'json'
require_relative '../lib/finder_pro'

module API
  class APP < Sinatra::Base
    configure :test do
      disable :protection # Disable protection in test env
    end

    set :bind, '0.0.0.0'
    set :port, 3000
    set :public_folder, File.expand_path('../public', __dir__)

    configure do
      enable :logging
      FinderPro::Services::ClientStore.load_from_file('data/clients.json')
    end

    helpers do
      def clients
        FinderPro::Services::ClientStore.all
      end

      def json_error(status, message, details = nil)
        status status
        { error: message, details: details }.to_json
      end
    end

    get '/query' do
      content_type :json
      query = params['q']
      field = params['field'] || 'full_name'
      page = (params['page'] || 1).to_i
      per_page = (params['per_page'] || 10).to_i

      return json_error(400, 'Missing query param `q`') if query.nil? || query.strip.empty?

      matches = FinderPro::Services::Searcher.search(clients, field, query)
      paginated = matches.slice((page - 1) * per_page, per_page) || []

      {
        total: matches.size,
        page: page,
        per_page: per_page,
        results: paginated.map(&:to_h),
      }.to_json
    end

    get '/duplicates' do
      page = (params['page'] || 1).to_i
      per_page = (params['per_page'] || 10).to_i

      begin
        duplicates = FinderPro::Services::DuplicateFinder.find_duplicates(clients)

        # Paginate the duplicates
        paginated_duplicates = duplicates
                               .flat_map { |_email, clients_array| clients_array }
                               .then do |array|
          FinderPro::Services::Pagination.paginate(array, page, per_page)
        end

        {
          total: duplicates.values.flatten.size,
          page: page,
          per_page: per_page,
          results: paginated_duplicates.map(&:to_h),
        }.to_json
      rescue JSON::ParserError => e
        status 500
        json_error(500, 'Invalid JSON data', e.message)
      rescue StandardError => e
        status 500
        json_error(500, 'Internal Server Error', e.message)
      end
    end

    post '/upload' do
      content_type :json

      unless params[:file] && params[:file][:tempfile]
        status 400
        return json_error(400, 'Missing file upload')
      end

      begin
        uploaded = JSON.parse(params[:file][:tempfile].read, symbolize_names: true)

        unless uploaded.is_a?(Array)
          status 422
          return json_error(422, 'Expected an array of client objects')
        end

        valid_clients = []
        errors = []

        uploaded.each_with_index do |data, idx|
          unless FinderPro::Models::Client.valid_data?(data)
            errors << { index: idx, data: data, error: 'Invalid client fields' }
            next
          end

          valid_clients << FinderPro::Models::Client.new(**data)
        end

        if errors.any?
          status 422
          return {
            error: 'Some records failed validation',
            details: errors,
            accepted_count: valid_clients.size,
          }.to_json
        end

        FinderPro::Services::ClientStore.replace(valid_clients)
        { message: 'Upload successful', count: valid_clients.size }.to_json
      rescue JSON::ParserError => e
        status 422
        json_error(422, 'Malformed JSON', e.message)
      rescue StandardError => e
        status 500
        json_error(500, 'Server error', e.message)
      end
    end

    # Serve Swagger UI
    get '/docs' do
      redirect '/docs/index.html'
    end

    # Start the app if this file is executed directly
    run! if app_file == $PROGRAM_NAME
  end
end
