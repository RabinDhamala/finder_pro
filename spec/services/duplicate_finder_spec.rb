# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/finder_pro_cli/models/client'
require_relative '../../lib/finder_pro_cli/services/duplicate_finder'

RSpec.describe FinderProCli::Services::DuplicateFinder do
  let(:clients) do
    [
      FinderProCli::Models::Client.new(id: 1, full_name: 'John Doe', email: 'john@example.com'),
      FinderProCli::Models::Client.new(id: 2, full_name: 'Jane Smith', email: 'jane@example.com'),
      FinderProCli::Models::Client.new(id: 3, full_name: 'Johnny Appleseed',
                                       email: 'john@example.com'),
    ]
  end

  it 'finds clients with duplicate emails' do
    duplicates = described_class.find_duplicates(clients)
    expect(duplicates.keys).to include('john@example.com')
    expect(duplicates['john@example.com'].size).to eq(2)
  end

  it 'returns empty hash if no duplicates found' do
    unique_clients = clients.uniq(&:email)
    duplicates = described_class.find_duplicates(unique_clients)
    expect(duplicates).to eq({})
  end
end
