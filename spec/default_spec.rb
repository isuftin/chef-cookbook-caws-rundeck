require 'spec_helper'

describe 'caws-rundeck::default' do
  mock_web_xml '????'
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  it 'includes the rundeck-server::default recipe' do
    expect(chef_run).to include_recipe('rundeck-server::install')
    expect(chef_run).to include_recipe('rundeck-server::config')
  end
end
