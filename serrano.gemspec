# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "serrano/version"

Gem::Specification.new do |s|
  s.name = "serrano"
  s.version = Serrano::VERSION
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = ">= 2.1"
  s.summary = "Crossref Client"
  s.description = "Low Level Ruby Client for the Crossref Search API"
  s.authors = "Scott Chamberlain"
  s.email = "myrmecocystus@gmail.com"
  s.homepage = "https://github.com/sckott/serrano"
  s.licenses = "MIT"

  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  s.require_paths = ["lib"]

  s.bindir = "bin"
  s.executables = ["serrano"]

  s.add_development_dependency "bundler", "~> 2.1", ">= 2.1.4"
  s.add_development_dependency "codecov", "~> 0.5.0"
  s.add_development_dependency "json", "~> 2.3", ">= 2.3.1"
  s.add_development_dependency "rake", "~> 13.0", ">= 13.0.1"
  s.add_development_dependency "standard", "~> 1.0"
  s.add_development_dependency "simplecov", "~> 0.21.2"
  s.add_development_dependency "test-unit", "~> 3.3", ">= 3.3.6"
  s.add_development_dependency "vcr", "~> 6.1"
  s.add_development_dependency "webmock", "~> 3.14"

  s.add_runtime_dependency "faraday", "~> 2.2"
  s.add_runtime_dependency "faraday-follow_redirects", "~> 0.1.0"
  s.add_runtime_dependency "multi_json", "~> 1.15"
  s.add_runtime_dependency "rexml", "~> 3.2", ">= 3.2.5"
  s.add_runtime_dependency "thor", "~> 1.2", ">= 1.2.1"

  s.metadata = {
    "homepage_uri" => "https://github.com/sckott/serrano",
    "documentation_uri" => "https://www.rubydoc.info/gems/serrano",
    "changelog_uri" =>
      "https://github.com/sckott/serrano/releases/tag/v#{s.version}",
    "source_code_uri" => "https://github.com/sckott/serrano",
    "bug_tracker_uri" => "https://github.com/sckott/serrano/issues"
  }
end
