# frozen_string_literal: true

require 'json'
require 'rspec'
require_relative '../../lib/finder_pro/models/client'
require_relative '../../lib/finder_pro/services/searcher'
require_relative '../support/fixtures_helper'

RSpec.describe FinderPro::Services::Searcher do
  include FixturesHelper

  let(:clients) do
    load_yaml_fixture('clients.yml')['clients'].map do |data|
      FinderPro::Models::Client.new(**data.transform_keys(&:to_sym))
    end
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
    expect(described_class.search(clients, 'invalid_field', 'something')).to be_empty
  end

  it 'returns empty if query is blank' do
    expect(described_class.search(clients, 'full_name', ' ')).to be_empty
  end

  it 'performs case-insensitive matching' do
    results = described_class.search(clients, 'full_name', 'JOHN')
    expect(results.map(&:full_name)).to include('John Doe', 'Johnny Appleseed')
  end

  it 'matches partial strings in email' do
    results = described_class.search(clients, 'email', '@sample')
    expect(results.map(&:email)).to include('johnny@sample.com')
  end

  it 'returns empty when no matches found' do
    expect(described_class.search(clients, 'full_name', 'Zebra')).to be_empty
  end
end
