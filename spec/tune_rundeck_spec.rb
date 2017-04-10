require 'spec_helper'

describe 'caws-rundeck::tune_rundeck' do
  context 'setup_ssl' do
    let(:solo) do
      ChefSpec::SoloRunner.new
    end

    let(:chef_run) do
      solo.converge(described_recipe) do |node|

      end

    end

    before do
      stub_command("echo $(($(cat /proc/sys/fs/file-max) > 65535)) | grep 0").and_return(false)
    end


    it 'runs a execute raise file-max' do
      expect(chef_run).to run_execute('raise file-max').with(command: 'echo 65535 > /proc/sys/fs/file-max')
    end

    it 'creates a template /.bashrc' do
      expect(chef_run).to create_template('/var/lib/rundeck/.bashrc')
    end

  end
end
