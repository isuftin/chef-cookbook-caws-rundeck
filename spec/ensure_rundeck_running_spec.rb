require 'spec_helper'

describe 'caws-rundeck::ensure_rundeck_running' do
  let(:solo) do
    ChefSpec::SoloRunner.new
  end

  let(:chef_run) do
    solo.converge(described_recipe) do |node|
    end
  end

  it 'Executes a test against localhost' do
    expect(chef_run).to run_execute("ensure api is up").with(command: 'curl -s -k -f http://localhost:4440')
  end
end
