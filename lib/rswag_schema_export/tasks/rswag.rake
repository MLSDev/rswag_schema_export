namespace :rswag do
  desc "schema_import"
  task :schema_import do
    puts('RSWAG SCHEMA_IMPORT')
    puts(fetch(:rswag_schema_export_disable_import, false))
    unless fetch(:rswag_schema_export_disable_import, false)
      on roles(fetch(:rswag_schema_export_roles, :app)) do
        within current_path do
          with rails_env: fetch(:rails_env) do
            execute :rake, "rswag:schema_import STAGE=#{fetch(:stage)}"
          end
        end
      end
    end
  end
end

after "deploy:finished", "rswag:schema_import"
