require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/test_*.rb']
  t.verbose = true
  t.warning = false
end

desc 'Run tests'
task default: :test

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
end

desc 'Build serrano docs'
task :docs do
  system 'yardoc'
end

desc 'bundle install'
task :bundle do
  system 'bundle install'
end

desc 'clean out builds'
task :clean do
  system 'ls | grep [0-9].gem | xargs rm'
end

desc 'Build serrano'
task :build do
  system 'gem build serrano.gemspec'
end

desc 'Install serrano'
task install: %i[bundle build] do
  system "gem install serrano-#{Serrano::VERSION}.gem"
end

desc 'Release to Rubygems'
task release: :build do
  system "gem push serrano-#{Serrano::VERSION}.gem"
end
