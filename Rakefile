require 'rake/testtask'

Rake::TestTask.new do |t|
  #t.libs << "test"
  t.test_files = FileList['*_test.rb']
  t.verbose = false
end

task :default => :test