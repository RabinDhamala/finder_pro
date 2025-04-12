# frozen_string_literal: true

require 'json'
require 'rspec'
require_relative '../../lib/finder_pro/services/client_loader'

RSpec.describe FinderPro::Services::ClientLoader do
  let(:json_data) do
    [
      { 'id' => 1, 'full_name' => 'John Doe', 'email' => 'john.doe@gmail.com' },
      { 'id' => 2, 'full_name' => 'Jane Smith', 'email' => 'jane.smith@yahoo.com' },
    ]
  end

  let(:test_file_path) { 'spec/tmp/test_clients.json' }

  before do
    # Ensure the directory exists before writing the test file
    FileUtils.mkdir_p('spec/tmp')
    File.write(test_file_path, JSON.generate(json_data))
  end

  after do
    File.delete(test_file_path)
  rescue StandardError
    nil
  end

  it 'loads clients from JSON file' do
    clients = described_class.load(test_file_path)
    expect(clients.size).to eq(2)
    expect(clients.first.full_name).to eq('John Doe')
    expect(clients.last.email).to eq('jane.smith@yahoo.com')
  end
end
