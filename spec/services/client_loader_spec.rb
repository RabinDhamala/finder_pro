# frozen_string_literal: true

require 'json'
require 'rspec'
require_relative '../../lib/finder_pro_cli/services/client_loader'

RSpec.describe FinderProCli::Services::ClientLoader do
  let(:json_data) do
    [
      { 'id' => 1, 'full_name' => 'John Doe', 'email' => 'john.doe@gmail.com' },
      { 'id' => 2, 'full_name' => 'Jane Smith', 'email' => 'jane.smith@yahoo.com' },
    ]
  end

  before do
    File.write('test_clients.json', JSON.generate(json_data))
  end

  after do
    File.delete('test_clients.json')
  end

  it 'loads clients from JSON file' do
    clients = described_class.load('test_clients.json')
    expect(clients.size).to eq(2)
    expect(clients.first.full_name).to eq('John Doe')
    expect(clients.last.email).to eq('jane.smith@yahoo.com')
  end
end
