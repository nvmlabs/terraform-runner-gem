require 'spec_helper'
require 'pry'

describe 'ConfigFile' do
  it 'returns valid data' do
    logger = dummy_logger
    ENV['aws_ssh_key_path'] = 'sshkeypath'
    config = ConfigFile.new('spec/mockdir/scripts/configs/tf_mock.json', logger)
    expect(config.environment).to eq('Testing Environment')
    expect(config.tf_file_path).to eq('spec/mockdir/scripts/tfmockdir')
    expect(config.variable_path).to eq('spec/mockdir/scripts/tfmockdir')
    expect(config.variable_files).to eq(['mock_vars1.tfvars', 'mock_vars2.tfvars'])
    expect(config.inline_variables).to eq({ 'aws_ssh_key_path' => 'sshkeypath', 'aws_ssh_key_name' => 'myawskey' })
    expect(config.state_file).to eq(
      {
        'type' => 's3',
        'config' => {
          'region' => 'eu-west-1',
          'bucket' => 'terraform-bucket',
          'key' => 'path/to/terraform.tfstate'
        }
      }
    )
    expect(config.custom_args).to eq(['-parallelism=10'])
    expect(config.modules_required).to eq(false)
  end

  describe 'file does not exist' do
    it 'exits with wonky data' do
      logger = LoggerHelper.get_logger('debug' => false)
      ENV['aws_ssh_key_path'] = 'sshkeypath'
      allow(File).to receive(:exist?).and_return(false)
      expect(logger).to receive(:fatal).with(/.*/)
      expect { ConfigFile.new('spec/mockdir/scripts/configs/tf_mock.json', logger) }.to raise_error SystemExit
    end
  end

  describe 'Config file with modules_required set to true' do
    it 'sets true if modules_required is true' do
      expect(new_config_with_modules.modules_required).to eq(true)
    end
  end
end
