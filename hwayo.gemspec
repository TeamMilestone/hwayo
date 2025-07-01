# frozen_string_literal: true

require_relative "lib/hwayo/version"

Gem::Specification.new do |spec|
  spec.name = "hwayo"
  spec.version = Hwayo::VERSION
  spec.authors = ["이원섭wonsup Lee/Alfonso"]
  spec.email = ["onesup.lee@gmail.com"]

  spec.summary = "Ruby wrapper for hwplib - Extract text from HWP files"
  spec.description = "Hwayo is a Ruby gem that wraps the hwplib Java library to extract text from Korean HWP (Hangul Word Processor) files. It provides a simple interface to extract text content from HWP documents using the Java hwplib library."
  spec.homepage = "https://github.com/onesup/hwayo"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir["{lib,sig}/**/*", "README.md", "Rakefile"].select { |f| File.file?(f) }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # JRuby support for Java integration
  spec.platform = 'java' if RUBY_PLATFORM == 'java'
  
  # No runtime dependencies needed - uses system Java directly

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
