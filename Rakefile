require 'rake/testtask'

Rake::TestTask.new do |t|
  #t.libs << "lib"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = false
end

task :default => :test

task :console do
  system "irb", "-Ilib", "-rgenetics"
end