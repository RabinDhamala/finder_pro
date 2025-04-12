#!/usr/bin/env ruby

require_relative '../lib/finder_pro_cli'
include FinderProCli::Services
include FinderProCli::Models

FILE_PATH = File.expand_path("../clients.json", __dir__)

clients = ClientLoader.load(FILE_PATH)

def display_client(client)
  puts "#{client.id}. #{client.full_name} - #{client.email}"
end

def print_help
  puts <<~HELP
    Usage:
      ruby bin/main.rb search <field> <query>   # Search clients by any field
      ruby bin/main.rb duplicates               # Find duplicate emails
  HELP
end

command = ARGV[0]
arg = ARGV[1]

case command
when "search"
  field = ARGV[1]
  query = ARGV[2..].join(" ") # support multi-word names

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
