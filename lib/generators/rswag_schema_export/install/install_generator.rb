require "rails/generators"

module RswagSchemaExport
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    def add_initializer
      template("rswag_schema_export.rb", "config/initializers/rswag_schema_export.rb")
    end
  end
end
