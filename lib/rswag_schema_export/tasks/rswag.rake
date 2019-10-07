namespace :rswag do
  desc 'schema_import'
  task :schema_import do
    on roles(fetch(:rswag_schema_export_roles, :app)) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'rswag:schema_import'
        end
      end
    end
  end
end

after  'deploy:finishing', 'rswag:schema_import'
