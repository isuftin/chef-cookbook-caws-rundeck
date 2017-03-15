require 'spec_helper'

describe 'caws-rundeck::setup_ssl' do
  context 'setup_ssl' do
    let(:solo) do
      ChefSpec::SoloRunner.new
    end

    let(:chef_run) do
      solo.converge(described_recipe) do |node|
        solo.resource_collection.insert(Chef::Resource::Service.new('rundeckd', solo.run_context))
      end

    end

    before do
      stub_data_bag_item("rundeck-_default", "rundeck_passwords").and_return({
          'ssl_password' => 'test'
      })
    end

    it 'Does not create a remote_file /root/ssl.crt' do
      expect(chef_run).to_not create_remote_file('/root/ssl.crt')
    end

    it 'Creates a remote_file /root/ssl.key' do
      expect(chef_run).to_not create_remote_file('/root/ssl.key')
    end
  end
end
