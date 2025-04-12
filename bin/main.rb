#!/usr/bin/env ruby

require_relative '../lib/finder_pro_cli'
include FinderProCli::Services
include FinderProCli::Models

def display_client(client)
  puts "#{client.id}. #{client.full_name} - #{client.email}"
end

def print_help
  puts <<~HELP
    📘 FinderPro CLI - Help

    Usage:
      ruby bin/main.rb [--file path/to/file.json] search <field> <query>
      ruby bin/main.rb [--file path/to/file.json] duplicates

    Examples:
      ruby bin/main.rb search email john@example.com
      ruby bin/main.rb --file data/clients_backup.json search full_name Jane
      ruby bin/main.rb duplicates

    Notes:
      - If --file is not provided, defaults to clients.json
      - Fields can be full_name, email, id, etc.
  HELP
end

# Extract file option if passed
args = ARGV.dup
data_file = "data/clients.json"  # default

if args.include?("--help") || args.empty?
  print_help
  exit
end

if args[0] == "--file"
  data_file = args[1]
  args.shift(2)
end

# Load data from JSON file
begin
  clients = ClientLoader.load(data_file)
rescue Errno::ENOENT
  puts "File not found: #{data_file}"
  exit 1
end

command = args[0]

case command
when "search"
  field = args[1]
  query = args[2..].join(" ")

  if field.nil? || query.strip.empty?
    puts "Usage: ruby bin/main.rb search <field> <query>"
    exit
  end

  results = Searcher.search(clients, field, query)

  if results.empty?
    puts "No matches found for '#{query}' in '#{field}'"
  else
    puts "Matches:"
    results.each { |c| display_client(c) }
  end
when "duplicates"
  duplicates = DuplicateFinder.find_duplicates(clients)
  if duplicates.empty?
    puts "No duplicate emails found."
  else
    puts "Duplicate emails found:"
    duplicates.each do |email, matches|
      puts "Email: #{email}"
      matches.each { |c| display_client(c) }
      puts "---"
    end
  end
else
  print_help
end
