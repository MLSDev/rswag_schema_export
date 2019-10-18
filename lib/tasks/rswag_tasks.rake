namespace :rswag do
  desc "Export schema.json to cloud storage"
  task schema_export: :environment do
    RswagSchemaExport::Export.new.run
  end

  desc "Import latest schema.json to app"
  task schema_import: :environment do
    RswagSchemaExport::Import.new.run
  end
end
