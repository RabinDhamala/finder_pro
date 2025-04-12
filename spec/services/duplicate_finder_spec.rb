# frozen_string_literal: true

require 'rspec'
require 'json'
require_relative '../../lib/finder_pro/models/client'
require_relative '../../lib/finder_pro/services/duplicate_finder'
require_relative '../support/fixtures_helper'

RSpec.describe FinderPro::Services::DuplicateFinder do
  include FixturesHelper

  let(:clients) do
    load_yaml_fixture('duplicate_clients.yml')['clients'].map do |data|
      FinderPro::Models::Client.new(**data.transform_keys(&:to_sym))
    end
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

  it 'correctly identifies multiple clients with the same email' do
    duplicates = described_class.find_duplicates(clients)
    expect(duplicates['john@example.com'].size).to eq(2)
    expect(duplicates['john@example.com'].map(&:full_name)).to contain_exactly('John Doe',
                                                                               'Johnny Appleseed')
  end

  it 'does not find duplicates if all emails are unique' do
    unique_clients = clients.reject { |client| client.email == 'john@example.com' }
    duplicates = described_class.find_duplicates(unique_clients)
    expect(duplicates).to eq({})
  end
end
