require 'rspec'
require 'rake'

RSpec.describe 'Rake Tasks: ' do
    before do
        load File.expand_path("../../Rakefile", __FILE__)
    end
  
    it 'Compile' do
        expect { Rake::Task['compile'].invoke }.not_to raise_exception
    end

    it 'Build' do
        expect { Rake::Task['build'].invoke }.not_to raise_exception
    end

  end