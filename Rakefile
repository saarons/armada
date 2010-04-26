# coding: UTF-8

require "rake"
require "spec/rake/spectask"

desc "Run all tests"
Spec::Rake::SpecTask.new("test") do |t|
  t.spec_opts = ["--color"]
  t.pattern = "test/**/*_spec.rb"
end