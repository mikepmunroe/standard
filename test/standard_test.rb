require_relative "test_helper"

class StandardTest < UnitTest
  def test_loads_stuff
    refute_nil RuboCop
    refute_nil Standard::Cli
    refute_nil RuboCop::Cop::Standard::BlockSingleLineBraces
    assert_instance_of Gem::Version, ::Standard::VERSION
  end

  BASE_CONFIG = "config/base.yml"
  INHERITED_OPTIONS = %w[
    Description
    Reference
    Safe
    SafeAutoCorrect
    StyleGuide
    VersionAdded
    VersionChanged
  ].freeze
  def test_configures_all_rubocop_and_performance_cops
    expected = Standard::BuildsConfig.new.call([])
      .rubocop_config_store
      .instance_variable_get(:@options_config)
      .instance_variable_get(:@hash)
      .sort.to_h
    actual = YAML.load_file(BASE_CONFIG)
    missing = (expected.keys - actual.keys).grep(/\//) # ignore groups like "Layout"
    extra = actual.keys - expected.keys - ["require"]
    if missing.any?
      puts "These cops need to be configured in `#{BASE_CONFIG}'. Defaults:"
      missing.each do |(name)|
        puts "\n#{name}:\n" + to_indented_yaml(expected[name], INHERITED_OPTIONS)
      end
    end

    assert_equal missing, [], "Configure these cops as either Enabled: true or Enabled: false in #{BASE_CONFIG}"
    assert_equal extra, [], "These cops do not exist and should not be configured in #{BASE_CONFIG}"
  end

  def test_alphabetized_config
    actual = YAML.load_file(BASE_CONFIG).keys - ["require"]
    expected = actual.sort

    assert_equal actual, expected, "Cop names should be alphabetized! (See this script to do it for you: https://github.com/testdouble/standard/pull/222#issue-744335213 )"
  end

  private

  def to_indented_yaml(cop_hash, without_keys = [])
    cop_hash.reject { |(k, v)|
      without_keys.include?(k)
    }.to_h.to_yaml.gsub(/^---\n/, "").gsub(/^/, "  ")
  end
end
