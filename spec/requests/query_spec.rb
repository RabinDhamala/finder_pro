# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

RSpec.describe 'GET /query', type: :request do
  let(:valid_clients) do
    YAML.load_file('spec/fixtures/clients.yml')
  end

  before do
    allow(ClientRepository).to receive(:all).and_return(valid_clients)
  end

  it 'returns matching clients' do
    get '/query', q: 'John'
    expect(last_response.status).to eq(200)
    results = JSON.parse(last_response.body)
    expect(results.any? { |c| c['full_name'].include?('John') }).to be true
  end

  it 'returns empty array if no matches found' do
    get '/query', q: 'Nonexistent'
    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body)).to eq([])
  end

  it 'returns 400 if query param is missing' do
    get '/query'
    expect(last_response.status).to eq(400)
    expect(JSON.parse(last_response.body)['error']).to eq('Missing query param')
  end

  it 'handles empty dataset' do
    allow(ClientRepository).to receive(:all).and_return([])

    get '/query', q: 'John'
    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body)).to eq([])
  end

  it 'handles JSON parsing errors' do
    allow(ClientRepository).to receive(:all).and_raise(JSON::ParserError.new('unexpected token'))

    get '/query', q: 'John'
    expect(last_response.status).to eq(500)
    expect(JSON.parse(last_response.body)['error']).to eq('Invalid JSON data')
  end

  it 'handles unexpected server errors' do
    allow(ClientRepository).to receive(:all).and_raise(StandardError.new('something went wrong'))

    get '/query', q: 'John'
    expect(last_response.status).to eq(500)
    expect(JSON.parse(last_response.body)['error']).to eq('Internal Server Error')
  end
end
