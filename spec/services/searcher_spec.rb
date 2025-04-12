# frozen_string_literal: true

require 'json'
require 'rspec'
require_relative '../../lib/finder_pro_cli/models/client'
require_relative '../../lib/finder_pro_cli/services/searcher'

RSpec.describe FinderProCli::Services::Searcher do
  let(:clients) do
    [
      FinderProCli::Models::Client.new(id: 1, full_name: 'John Doe', email: 'john@example.com'),
      FinderProCli::Models::Client.new(id: 2, full_name: 'Jane Smith', email: 'jane@example.com'),
      FinderProCli::Models::Client.new(id: 3, full_name: 'Johnny Appleseed',
                                       email: 'johnny@sample.com'),
    ]
  end

  it 'searches by full_name' do
    results = described_class.search(clients, 'full_name', 'john')
    expect(results.map(&:full_name)).to include('John Doe', 'Johnny Appleseed')
  end

  it 'searches by email' do
    results = described_class.search(clients, 'email', 'example')
    expect(results.map(&:email)).to include('john@example.com', 'jane@example.com')
  end

  it 'returns empty if field is invalid' do
    results = described_class.search(clients, 'unknown_field', 'anything')
    expect(results).to eq([])
  end

  it 'returns empty if query is empty' do
    results = described_class.search(clients, 'full_name', ' ')
    expect(results).to eq([])
  end
end
