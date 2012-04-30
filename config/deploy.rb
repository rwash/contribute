$:.unshift(File.expand_path('./lib', ENV['rvm_path']))

require 'bundler/capistrano'
require "rvm/capistrano" 

set :rvm_ruby_string, 'ruby-1.9.3-p194' 

set :application, "contribute"

set :scm, :git
set :branch, "master"
set :repository,  "ssh://rwash@orithena.cas.msu.edu/projects/contribute.git"
#set :deploy_via, :remote_cache

set :user, "rwash"

default_run_options[:pty] = true

set :deploy_to, "/websites/contribute"

role :web, "contribute.cas.msu.edu"                          # Your HTTP server, Apache/etc
role :app, "contribute.cas.msu.edu"                          # This may be the same as your `Web` server
role :db,  "contribute.cas.msu.edu", :primary => true # This is where Rails migrations will run

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
