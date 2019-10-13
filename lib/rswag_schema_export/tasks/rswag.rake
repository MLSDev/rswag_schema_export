namespace :rswag do
  desc 'schema_import'
  task :schema_import do
    on roles(fetch(:rswag_schema_export_roles, :app)) do
      within current_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "rswag:schema_import STAGE=#{fetch(:rswag_schema_export_stage, 'develop')}"
        end
      end
    end
  end
end

after  'deploy:finished', 'rswag:schema_import'
