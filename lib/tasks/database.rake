namespace :db do
  task :restore => "latest.dump" do
    Rake::Task["db:drop:all"].invoke
    Rake::Task["db:create:all"].invoke
    sh "pg_restore --no-owner --no-privileges --dbname scoutinv_development latest.dump"
    Rake::Task["db:migrate"].invoke
    sh "psql --dbname scoutinv_development --command \"DELETE FROM active_storage_attachments\""
    sh "psql --dbname scoutinv_development --command \"DELETE FROM active_storage_blobs\""
  end
end

file "latest.dump" do
  sh "heroku pg:backups:download"
end
