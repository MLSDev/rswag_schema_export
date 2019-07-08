module RswagSchemaExport
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/rswag_tasks.rake"
    end
  end
end
