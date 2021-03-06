require 'spec_helper'

describe 'InputChecker' do
  describe '#validate_config_file_supplied' do
    it 'must exit if no config is supplied' do
      opts = Options.get_options(['-a', 'plan'])
      ic = InputChecker.new(opts, dummy_logger)
      expect(ic.send(:validate_config_file_supplied, nil)).to eq('You have not supplied a config file.')
    end

    it 'must exit if config file does not exist.' do
      ic = InputChecker.new(nil, dummy_logger)
      expect(ic.send(:validate_config_file_exist, '/dummy/plan.json')).to eq('The config file path seems to be missing or not valid.')
    end
  end

  describe '#validate_action' do
    it 'must exit if action is invalid' do
      ic = InputChecker.new(nil, dummy_logger)
      expect(ic.send(:validate_action, 'trash')).to eq('Invalid action: trash')
      expect(ic.send(:validate_action, 'get')).to_not eq(nil)
    end

    it 'must return nil if the value is correct' do
      ic = InputChecker.new(nil, dummy_logger)
      expect(ic.send(:validate_action, 'plan')).to eq(nil)
      expect(ic.send(:validate_action, 'destroy')).to eq(nil)
      expect(ic.send(:validate_action, 'apply')).to eq(nil)
    end
  end

  describe '#validate_custom_parameters' do
    it 'should look for failed converstions and pick on up' do
      ic = InputChecker.new(nil, dummy_logger)
      expect(ic.send(:validate_custom_parameters, ['custom_parameter_failed', '-destory'])).to eq('Invalid custom parameters parameters.')
    end

    it 'should look for failed converstions and not find one' do
      ic = InputChecker.new(nil, dummy_logger)
      expect(ic.send(:validate_custom_parameters, ['-no-color', '-destory'])).to eq(nil)
    end
  end
end
