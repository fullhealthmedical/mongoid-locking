# frozen_string_literal: true

require_relative "lib/mongoid/locking/version"

Gem::Specification.new do |spec|
  spec.name = "mongoid-locking"
  spec.version = Mongoid::Locking::VERSION
  spec.authors = ["Rodrigo RA"]
  spec.email = ["rodrigorcomp@gmail.com"]

  spec.summary = "Implements optimistic locking for Mongoid objects."
  spec.description = "Implements optimistic locking for Mongoid objects."
  spec.homepage = "https://github.com/fullhealthmedical/mongoid-locking"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/fullhealthmedical/mongoid-locking"
  spec.metadata["changelog_uri"] = "https://github.com/fullhealthmedical/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "mongoid", "~> 7.2"

  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-rspec"
  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
