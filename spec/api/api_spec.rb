# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'
require_relative '../../api/app'

RSpec.describe API::APP do
  include Rack::Test::Methods

  def app
    API::APP
  end

  let(:fixture_path) { File.expand_path('../../fixtures/clients.json', __dir__) }

  describe 'GET /query' do
    context 'when query param is missing' do
      it 'returns 400' do
        get '/query'
        expect(last_response.status).to eq(400)
        expect(last_response.body).to include('Missing query param')
      end
    end

    context 'with valid query' do
      it 'returns search results' do
        get '/query', q: 'Jane', field: 'full_name'
        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['results'].any?).to be true
      end

      it 'supports pagination' do
        get '/query', q: 'Jane', field: 'full_name', page: 1, per_page: 1
        expect(last_response.status).to eq(200)
        json = JSON.parse(last_response.body)
        expect(json['results'].size).to eq(1)
      end
    end
  end

  describe 'GET /duplicates' do
    it 'returns duplicate emails if present' do
      get '/duplicates'
      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json['results'].any?).to be true
    end

    it 'supports pagination' do
      get '/duplicates', page: 1, per_page: 1
      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json['results'].size).to eq(1)
    end
  end

  describe 'POST /upload' do
    def uploaded_file_with_content(content)
      file = Tempfile.new(['upload', '.json'])
      file.write(content)
      file.rewind
      Rack::Test::UploadedFile.new(file.path, 'application/json')
    end

    it 'uploads and replaces clients with valid data' do
      data = [
        { id: 5, full_name: 'New User', email: 'new@example.com' }
      ].to_json

      file = uploaded_file_with_content(data)

      post '/upload', file: file

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('Upload successful')
    end

    it 'returns error for malformed JSON' do
      file = uploaded_file_with_content('{invalid')

      post '/upload', file: file

      expect(last_response.status).to eq(422)
      expect(last_response.body).to include('Malformed JSON')
    end

    it 'returns validation errors for bad records' do
      data = [
        { id: nil, full_name: '', email: 'bad' },
        { id: 6, full_name: 'Good User', email: 'good@example.com' }
      ].to_json

      file = uploaded_file_with_content(data)

      post '/upload', file: file

      expect(last_response.status).to eq(422)
      expect(last_response.body).to include('Some records failed validation')
    end
  end
end
