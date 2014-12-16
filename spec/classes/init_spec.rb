require 'spec_helper'
describe 'securerootpass' do

  context 'with defaults for all parameters' do
    it { should contain_class('securerootpass') }
  end
end
