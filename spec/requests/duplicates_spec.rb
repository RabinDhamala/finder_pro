# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

RSpec.describe 'GET /duplicates', type: :request do
  let(:valid_clients) do
    YAML.load_file('spec/fixtures/clients.yml')
  end

  before do
    allow(FinderProCli::Services::ClientStore).to receive(:all).and_return(valid_clients)
  end

  it 'returns duplicates correctly with pagination' do
    get '/duplicates?page=1&per_page=1' # Test for first page with 1 result per page

    expect(last_response.status).to eq(200)
    body = JSON.parse(last_response.body)
    expect(body).to be_a(Array)
    expect(body.size).to eq(1) # Only one result on the first page
  end

  it 'returns duplicates correctly on second page' do
    get '/duplicates?page=2&per_page=1' # Test for second page with 1 result per page

    expect(last_response.status).to eq(200)
    body = JSON.parse(last_response.body)
    expect(body).to be_a(Array)
    expect(body.size).to eq(1) # Only one result on the second page
  end

  it 'returns empty if page is out of range' do
    get '/duplicates?page=999&per_page=1'

    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body)).to eq([])
  end

  it 'handles empty dataset' do
    allow(FinderProCli::Services::ClientStore).to receive(:all).and_return([])

    get '/duplicates'
    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body)).to eq({})
  end

  it 'ignores clients with missing email field' do
    incomplete_clients = [
      { 'id' => 1, 'full_name' => 'John Doe' },
      { 'id' => 2, 'email' => 'jane@example.com' },
      { 'id' => 3, 'full_name' => 'Alex Johnson', 'email' => 'john@example.com' },
    ]
    allow(FinderProCli::Services::ClientStore)
      .to receive(:all)
      .and_return(incomplete_clients)

    get '/duplicates'
    expect(last_response.status).to eq(200)
    body = JSON.parse(last_response.body)
    expect(body.keys).to_not include(nil)
  end

  it 'handles JSON parsing errors' do
    allow(FinderProCli::Services::ClientStore)
      .to receive(:all)
      .and_raise(JSON::ParserError.new('unexpected token'))

    get '/duplicates'
    expect(last_response.status).to eq(500)
    expect(JSON.parse(last_response.body)['error']).to eq('Invalid JSON data')
  end

  it 'handles unexpected server errors' do
    allow(FinderProCli::Services::ClientStore)
      .to receive(:all)
      .and_raise(StandardError.new('something went wrong'))

    get '/duplicates'
    expect(last_response.status).to eq(500)
    expect(JSON.parse(last_response.body)['error']).to eq('Internal Server Error')
  end
end
