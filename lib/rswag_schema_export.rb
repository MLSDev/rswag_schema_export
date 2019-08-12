require "rswag_schema_export/version"
require 'rswag_schema_export/configuration'
require "rswag_schema_export/railtie" if defined?(Rails)
require "rswag_schema_export/schema_export"
require "rswag_schema_export/schema_import"

module RswagSchemaExport
  def self.configure
    yield(config)
  end

  def self.config
    @config ||= Configuration.new
  end
end
