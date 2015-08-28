require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

desc "Run tests"
task :default => :test

desc "Build crossrefrb"
task :build do
	system "gem build crossrefrb.gemspec"
end

desc "Install crossrefrb"
task :install => :build do
	system "gem install crossrefrb-#{Crossref::VERSION}.gem"
end

desc "Release to Rubygems"
task :release => :build do
  system "gem push crossrefrb-#{Crossref::VERSION}.gem"
end
