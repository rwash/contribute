#I'm not a contribute specific task, I was found on the internet.
#I serve to run db:seed on the test DB so there are categories and such there when they are needed
namespace :db do
  namespace :test do
    task :prepare => :environment do
      Rake::Task["db:seed"].invoke
    end
  end
end
