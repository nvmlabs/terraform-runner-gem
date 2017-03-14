# Copyright 2017 Randy Coburn
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'json'
class ConfigFile
  attr_reader :environment, :tf_file_path, :variable_path, :variable_files
  attr_reader :inline_variables, :state_file, :custom_args, :modules_required

  def initialize(configuration_location, logger)
    @logger = logger
    @base_dir = Dir.pwd
    validate_config(convert_json_to_ruby(configuration_location))
  end

  def convert_json_to_ruby(config_file)
    # Load the configuration file specified
    # TODO Handle the JSON convert failure
    config_file_data = JSON.parse(IO.read(File.join(@base_dir, config_file)))

    @logger.debug("Collected config file: #{config_file_data}")
    return config_file_data
  end

  def file_exist(*args)
    fp = File.expand_path(File.join(@base_dir, args))
    return File.exist?(fp) ? nil : "File not found: #{fp}.\n"
  end

  def directory_exists(*args)
    fp = File.expand_path(File.join(@base_dir, args))
    return File.directory?(fp) ? nil : "Could not find directory: #{fp}.\n"
  end

  def convert_inline_var(hash)
    hash.each do |key, v|
      hash[key] = eval(v.delete('${}')) if v =~ /^\$\{ENV/ && v =~ /\}$/
    end unless hash.nil?
    return hash
  end

  def validate_config(config_json)
    errors = []
    # Is the directory and files stated in the config file available.
    @logger.debug('Is the variable file there?')
    config_json['variable_files'].each do |var_file|
      errors << file_exist(config_json['variable_path'], var_file)
    end unless config_json['variable_files'].nil?

    # Is the source directory there?
    @logger.debug('Is the source code dir there?')
    errors << directory_exists(config_json['tf_file_path'])
    EXIT.fatal_error(@logger, errors, 1) unless errors.compact.empty?

    create_att_readers(config_json)
  end

  def create_att_readers(config_json)
    @environment = config_json['environment']
    @tf_file_path = config_json['tf_file_path']
    @variable_path = config_json['variable_path']
    @variable_files = config_json['variable_files']
    @inline_variables = convert_inline_var(config_json['inline_variables'])
    @state_file = config_json['state_file']
    @custom_args = config_json['custom_args']
    @modules_required = config_json['modules_required'].nil? ? false : config_json['modules_required']
  end

  private :validate_config, :directory_exists, :file_exist, :convert_json_to_ruby
  private :convert_inline_var
end
