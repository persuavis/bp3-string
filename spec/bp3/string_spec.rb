# frozen_string_literal: true

require_relative '../../lib/bp3/string/test'

# require 'action_view'
require 'action_controller/railtie'

module TestSpace
  class TestModel < ActiveRecord::Base
    self.table_name = 'test_space_test_models'
  end

  class TestModelsController < ::ActionController::Base
  end

  class TestModelController < ::ActionController::Base
  end
end

# rubocop:disable RSpec/ExpectActual
RSpec.describe Bp3::String do
  before do
    String.include Bp3::String::Modelize
    String.include Bp3::String::Controllerize
  end

  it 'has a version number' do
    expect(Bp3::String::VERSION).not_to be_nil
  end

  describe '#modelize' do
    it 'responds to #modelize' do
      expect('some string').to respond_to(:modelize)
    end

    it 'modelizes' do
      # allow(Bp3::String::TableModelMap).to receive(:testing?).and_return(false)
      expect('some_string'.modelize).to eq('SomeString')
      expect('test'.modelize).to eq('Test')
      expect('bp3_string_test'.modelize).to eq('Bp3::String::Test')
      expect('test_space_test_models'.modelize).to eq('TestSpace::TestModel')
    end
  end

  describe '#controllerize' do
    it 'responds to #controllerize' do
      expect('some string').to respond_to(:controllerize)
    end

    it 'controllerizes basic cases' do
      expect('some_string'.controllerize).to eq('SomeStringsController')
      expect('test'.controllerize).to eq('TestsController')
      expect('bp3_string_test'.controllerize).to eq('Bp3::String::TestsController')
    end

    it 'controllerizes complex cases' do
      expect('test_space_test_models'.controllerize).to eq('TestSpace::TestModelsController')
      expect('test_space_test_model'.controllerize).to eq('TestSpace::TestModelsController')
    end
  end

  describe '.reset_cache' do
    it 'resets the controller-map cache' do
      'string'.controllerize
      expect(Bp3::String::TableControllerMap.instance_variable_get(:@cached_hash)).not_to be_nil
      Bp3::String::TableControllerMap.reset_cached_hash
      expect(Bp3::String::TableControllerMap.instance_variable_get(:@cached_hash)).to be_nil
    end

    it 'resets the model-map cache' do
      'string'.modelize
      expect(Bp3::String::TableModelMap.instance_variable_get(:@cached_hash)).not_to be_nil
      Bp3::String::TableModelMap.reset_cached_hash
      expect(Bp3::String::TableModelMap.instance_variable_get(:@cached_hash)).to be_nil
    end
  end
end
# rubocop:enable RSpec/ExpectActual
