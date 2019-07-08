lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rswag_schema_export/version"

Gem::Specification.new do |spec|
  spec.name          = "rswag_schema_export"
  spec.version       = RswagSchemaExport::VERSION
  spec.authors       = ["Ruslan Tolstov"]
  spec.email         = ["ruslan.tolstov.ua@gmail.com"]

  spec.summary       = "Export/Import your rswag schema.json during deploy with CI"
  spec.description   = "rswag_schema_export"
  spec.homepage      = "https://github.com/MLSDev/rswag_schema_export"
  spec.license       = "MIT"

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec|features)/}) }
  end
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk-s3", "~> 1"

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "railties", ">= 3.1", "< 6.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "simplecov"
end
