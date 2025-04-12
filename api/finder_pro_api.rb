# frozen_string_literal: true

require 'sinatra/base'
require 'json'
require_relative '../lib/finder_pro_cli'

module FinderProCli
  class API < Sinatra::Base
    configure :test do
      disable :protection # Disable protection in test env
    end

    set :bind, '0.0.0.0'
    set :port, 3000
    set :public_folder, File.expand_path('../public', __dir__)

    configure do
      enable :logging
      FinderProCli::Services::ClientStore.load_from_file('data/clients.json')
    end

    helpers do
      def clients
        FinderProCli::Services::ClientStore.all
      end
    end

    get '/query' do
      content_type :json
      query = params['q']
      field = params['field'] || 'full_name'
      page = (params['page'] || 1).to_i
      per_page = (params['per_page'] || 10).to_i

      if query.nil? || query.strip.empty?
        status 400
        return { error: 'Missing query param `q`' }.to_json
      end

      matches = FinderProCli::Services::Searcher.search(clients, field, query)
      paginated = matches.slice((page - 1) * per_page, per_page) || []

      {
        total: matches.size,
        page: page,
        per_page: per_page,
        results: paginated.map(&:to_h),
      }.to_json
    end

    get '/duplicates' do
      logger.info 'Handling /duplicates request'
      content_type :json
      dups = FinderProCli::Services::DuplicateFinder.find_duplicates(clients)
      # Flatten and convert to array of hashes
      duplicates = dups.values.flatten.map(&:to_h)

      {
        count: duplicates.size,
        duplicates: duplicates,
      }.to_json
    end

    post '/upload' do
      content_type :json

      unless params[:file] && params[:file][:tempfile]
        status 400
        return { error: 'Missing file upload' }.to_json
      end

      begin
        uploaded = JSON.parse(params[:file][:tempfile].read, symbolize_names: true)

        unless uploaded.is_a?(Array)
          status 422
          return { error: 'Expected an array of client objects' }.to_json
        end

        valid_clients = []
        errors = []

        uploaded.each_with_index do |data, idx|
          unless FinderProCli::Models::Client.valid_data?(data)
            errors << { index: idx, data: data, error: 'Invalid client fields' }
            next
          end

          valid_clients << FinderProCli::Models::Client.new(**data)
        end

        if errors.any?
          status 422
          return {
            error: 'Some records failed validation',
            details: errors,
            accepted_count: valid_clients.size,
          }.to_json
        end

        FinderProCli::Services::ClientStore.replace(valid_clients)
        { message: 'Upload successful', count: valid_clients.size }.to_json
      rescue JSON::ParserError => e
        status 422
        { error: 'Malformed JSON', details: e.message }.to_json
      rescue StandardError => e
        status 500
        { error: 'Server error', details: e.message }.to_json
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
