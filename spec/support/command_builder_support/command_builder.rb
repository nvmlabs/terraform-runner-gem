def create_CommandBuilder(options, config_file, logger)
  cmd = CommandBuilder.new(options, config_file, logger)
  allow(cmd).to receive(:terraform_bin).and_return('/usr/bin/terraform')
  return cmd
end

def new_config
  return ConfigFile.new('spec/mockdir/scripts/configs/tf_mock.json', dummy_logger)
end

def new_config_with_modules
  return ConfigFile.new('spec/mockdir/scripts/configs/tf_mock_modules.json', dummy_logger)
end
