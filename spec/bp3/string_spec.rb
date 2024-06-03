# frozen_string_literal: true

require_relative '../../lib/bp3/string/test'

class Test < ActiveRecord::Base
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
      allow(Bp3::String::TableModelMap).to receive(:testing?).and_return(false)

      expect('some_string'.modelize).to eq('SomeString')
      expect('test'.modelize).to eq('Test')
      expect('bp3_string_test'.modelize).to eq('Bp3::String::Test')
    end
  end

  describe '#controllerize' do
    it 'responds to #controllerize' do
      expect('some string').to respond_to(:controllerize)
    end

    it 'controllerizes' do
      allow(Bp3::String::TableControllerMap).to receive(:testing?).and_return(false)

      expect('some_string'.controllerize).to eq('SomeStringController')
      expect('test'.controllerize).to eq('TestsController')
      expect('bp3_string_test'.controllerize).to eq('Bp3::String::TestsController')
    end
  end
end
# rubocop:enable RSpec/ExpectActual
