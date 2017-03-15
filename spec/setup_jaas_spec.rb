require 'spec_helper'

describe 'caws-rundeck::setup_jaas' do
  context 'setup_jaas' do
    let(:solo) do
      ChefSpec::SoloRunner.new
    end

    let(:chef_run) do
      solo.converge(described_recipe) do |node|
        node.default['rundeck_server'] = { 'confdir' => '/tmp'}
        solo.resource_collection.insert(Chef::Resource::Service.new('rundeckd', solo.run_context))
      end
    end

    it 'creates a jaas template with attributes' do
      expect(chef_run).to create_template('jaas-template').with(
        user:   'rundeck',
        group:  'rundeck'
      )
    end
  end
end
