require_relative '../spec_helper'

describe 'samba::server' do
  before(:each) do
    samba_shares = {
      'id' => 'shares',
      'shares' => {
        'export' => {
          'comment' => 'Exported Share',
          'path' => '/srv/export',
          'guest ok' => 'no',
          'printable' => 'no',
          'write list' => ['smbuser'],
          'create mask' => '0664',
          'directory mask' => '0775'
        }
      }
    }
    samba_users = [{
      'id' => 'jtimberman',
      'smbpasswd' => 'plaintextpassword'
    }]

    stub_data_bag_item('samba', 'shares').and_return(samba_shares)
    stub_search('users', '*:*').and_return(samba_users)
  end

  context 'ubuntu' do
    let(:chef_run) do
      ChefSpec::Runner.new(
        :platform => 'ubuntu',
        :version => '14.04'
      ).converge(described_recipe)
    end

    it 'installs samba' do
      expect(chef_run).to install_package 'samba'
    end

    it 'manages smb.conf' do
      expect(chef_run).to create_template('/etc/samba/smb.conf')
    end

    it 'notifies samba services to restart when updating the config' do
      resource = chef_run.template('/etc/samba/smb.conf')
      expect(resource).to notify('service[smbd]').to(:restart)
      expect(resource).to notify('service[nmbd]').to(:restart)
    end

    it 'manages the samba service(s)' do
      expect(chef_run).to enable_service('smbd')
      expect(chef_run).to enable_service('nmbd')
      expect(chef_run).to start_service('smbd')
      expect(chef_run).to start_service('nmbd')
    end
  end

  context 'debian' do
    let(:chef_run) do
      ChefSpec::Runner.new(
        :platform => 'debian',
        :version => '7.5'
      ).converge(described_recipe)
    end

    it 'installs samba' do
      expect(chef_run).to install_package 'samba'
    end

    it 'manages smb.conf' do
      expect(chef_run).to create_template('/etc/samba/smb.conf')
    end

    it 'notifies samba services to restart when updating the config' do
      resource = chef_run.template('/etc/samba/smb.conf')
      expect(resource).to notify('service[samba]').to(:restart)
    end

    it 'manages the samba service(s)' do
      expect(chef_run).to enable_service('samba')
      expect(chef_run).to start_service('samba')
    end
  end

  context 'centos' do
    let(:chef_run) do
      ChefSpec::Runner.new(
        :platform => 'centos',
        :version => '6.5'
      ).converge(described_recipe)
    end

    it 'installs samba' do
      expect(chef_run).to install_package 'samba'
    end

    it 'manages smb.conf' do
      expect(chef_run).to create_template('/etc/samba/smb.conf')
    end

    it 'notifies samba services to restart when updating the config' do
      resource = chef_run.template('/etc/samba/smb.conf')
      expect(resource).to notify('service[smb]').to(:restart)
      expect(resource).to notify('service[nmb]').to(:restart)
    end

    it 'manages the samba service(s)' do
      expect(chef_run).to enable_service('smb')
      expect(chef_run).to enable_service('nmb')
      expect(chef_run).to start_service('smb')
      expect(chef_run).to start_service('nmb')
    end
  end
end