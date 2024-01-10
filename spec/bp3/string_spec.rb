# frozen_string_literal: true

# rubocop:disable RSpec/ExpectActual
RSpec.describe Bp3::String do
  before do
    String.include Bp3::String::Modelize
    String.include Bp3::String::Controllerize
  end

  it 'has a version number' do
    expect(Bp3::String::VERSION).not_to be_nil
  end

  it '#modelize' do
    expect('some string').to respond_to(:modelize)
  end

  it '#controllerize' do
    expect('some string').to respond_to(:controllerize)
  end
end
# rubocop:enable RSpec/ExpectActual
