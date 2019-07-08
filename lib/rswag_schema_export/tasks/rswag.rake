require "rswag_schema_export/schema_import"

namespace :rswag do
  desc "Import latest schema.json to app"
  task :schema_import do
    on roles(:all) do
      stage = ENV["STAGE"] || fetch(:stage, "develop")
      RswagSchemaExport::Import.new.run(stage) do
        upload!("schema.json", "#{current_path}/#{ENV['RSWAG_SCHEMA_PATH']}")
      end
    end
  end
end
