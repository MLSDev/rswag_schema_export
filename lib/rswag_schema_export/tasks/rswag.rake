require "rswag_schema_export/schema_import"

namespace :rswag do
  desc "Import latest schema.json to app"
  task :schema_import do
    on roles(:all) do
      stage = ENV["STAGE"] || fetch(:stage, "develop")
      RswagSchemaExport::Import.new.run(stage) do
        RswagSchemaExport.config.shemas.map do |schema|
          upload!(schema, "#{current_path}/#{schema}")
        end
      end
    end
  end
end
