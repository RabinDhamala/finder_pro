# frozen_string_literal: true

require 'spec_helper'
require 'open3'

RSpec.describe 'FinderPro CLI' do
  let(:cli) { './bin/cli.rb' }

  describe 'search command' do
    context 'when arguments are correct' do
      it 'returns search results for valid query' do
        stdout, stderr, status = Open3.capture3("ruby #{cli} search email john.doe@gmail.com")
        expect(status.success?).to be true
        expect(stdout).to include('Matches:')
        expect(stdout).to include('john.doe@gmail.com')
        expect(stderr).to be_empty
      end
    end

    context 'when query is missing' do
      it 'shows usage information' do
        stdout, stderr, status = Open3.capture3("ruby #{cli} search email")
        expect(status.success?).to be true
        expect(stdout).to include('FinderPro CLI - Help')
        expect(stderr).to be_empty
      end
    end

    context 'when command is incomplete' do
      it 'shows usage information when params are incomplete' do
        stdout, stderr, status = Open3.capture3("ruby #{cli} search")
        expect(status.success?).to be true
        expect(stdout).to include('FinderPro CLI - Help')
        expect(stderr).to be_empty
      end
    end

    context 'when query does not match anything' do
      it 'returns no matches' do
        stdout, stderr, status =
          Open3.capture3("ruby #{cli} search email nonexistent.email@example.com")
        expect(status.success?).to be true
        expect(stdout).to include('No matches found')
        expect(stderr).to be_empty
      end
    end
  end

  describe 'incorrect commands' do
    it 'shows usage when the command is incorrect' do
      stdout, stderr, status = Open3.capture3("ruby #{cli} unknown_command")
      expect(status.success?).to be true
      expect(stdout).to include('Usage:')
      expect(stdout).to include('ruby bin/cli.rb [--file path/to/file.json] search <field> <query>')
      expect(stderr).to be_empty
    end
  end
end
