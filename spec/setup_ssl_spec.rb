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

     it 'writes log files' do
      expect(chef_run).to write_log('SSL Source data bag: rundeck-_default/rundeck_passwords').with(level: :debug)
      expect(chef_run).to write_log('SSL password attribute: ssl_password').with(level: :debug)
      expect(chef_run).to write_log('SSL key password attribute: ').with(level: :debug)
      expect(chef_run).to write_log('SSL cert file location: ').with(level: :debug)
      expect(chef_run).to write_log('SSL key file location: ').with(level: :debug)
    end

    it 'Does not create a remote_file /root/ssl.crt' do
      expect(chef_run).to_not create_remote_file('/root/ssl.crt')
    end

    it 'Creates a remote_file /root/ssl.key' do
      expect(chef_run).to_not create_remote_file('/root/ssl.key')
    end

    it 'runs a execute Create keystore' do
      expect(chef_run).to run_execute('Create keystore')
        .with(command: "/usr/bin/keytool -genkey -noprompt -keystore /etc/rundeck/ssl/keystore  -alias 'rundeck' -keyalg RSA -keypass test -storepass test -dname 'CN=fauxhai.local, OU={}, O={}, L={}, S={}, C={}'")
    end

    it 'creates a remote_file for trust store' do
      expect(chef_run).to create_remote_file('Copy keystore to truststore').with(path: '/etc/rundeck/ssl/truststore')
    end

    it 'creates a file for keystore location' do
      expect(chef_run).to create_file('/etc/rundeck/ssl/keystore').with(path: '/etc/rundeck/ssl/keystore')
    end

    it 'creates a file for truststore location' do
      expect(chef_run).to create_file('/etc/rundeck/ssl/truststore').with(path: '/etc/rundeck/ssl/truststore')
    end

    it 'creates a template when specifying the identity attribute' do
      expect(chef_run).to create_template('/etc/rundeck/ssl/ssl.properties').with(path: '/etc/rundeck/ssl/ssl.properties')
    end
  end
end
