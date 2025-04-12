# frozen_string_literal: true

require 'yaml'

module FixturesHelper
  def load_yaml_fixture(filename)
    YAML.load_file(File.join(__dir__, '../fixtures', filename))
  end
end
