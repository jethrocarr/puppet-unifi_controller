require 'spec_helper'
describe 'unifi_controller' do

  context 'with defaults for all parameters' do
    it { should contain_class('unifi_controller') }
  end
end
