Rake::TaskManager.class_eval do
  def remove_task(task_name)
    @tasks.delete(task_name.to_s)
  end
end

# lib/tasks/db/test.rake
Rake.application.remove_task "db:test:prepare"

namespace :db do
  namespace :test do
    task :prepare do
      system("bin/rails db:migrate RAILS_ENV=test")
    end
  end
end
