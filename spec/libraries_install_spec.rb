require 'spec_helper'

describe 'caws-rundeck::libraries_install' do
  let(:solo) do
    ChefSpec::SoloRunner.new
  end

  let(:chef_run) do
    solo.converge(described_recipe) do |node|
      node.default['rundeck_server'] = { 'basedir' => '/tmp'}
    end
  end

  it 'installs python' do
    expect(chef_run).to install_package('python')
    expect(chef_run).to upgrade_package('python')
  end

  it 'installs python-pip' do
    expect(chef_run).to install_package('python-pip')
  end

  it 'installs python-virtualenv' do
    expect(chef_run).to install_package('python-virtualenv')
  end

  it 'Creates a remote_file resource' do
    expect(chef_run).to create_remote_file_if_missing('get_latest_jq').with(owner: 'rundeck')
  end

  it 'creates a link to the specified target' do
    link = chef_run.link('/usr/bin/jq')
    expect(link).to link_to('/var/lib/rundeck/jq-1.5')
  end
end
