require 'rake'
begin
  require 'spec/rake/spectask'
rescue LoadError
  puts "Please install RSpec"
end


desc "Run all tests"
Spec::Rake::SpecTask.new('test') do |t|
  t.spec_opts = ["--color"]
  t.pattern = "test/**/*_spec.rb"
end