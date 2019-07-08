namespace :rswag do
  desc "Import latest schema.json to app"
  task :schema_import do
    on roles(:all) do
      RswagSchemaExport::Import.new.run do
        upload!("schema.json", "#{current_path}/#{ENV['RSWAG_SCHEMA_PATH']}")
      end
    end
  end
end
