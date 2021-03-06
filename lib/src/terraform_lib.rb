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

class TerraformRunner
  # This is used to hold the value of the terraform exit code from the run.
  # Mostly useful during the plan runs.
  attr_reader :tf_exit_code

  def initialize(logger, options)
    @tf_exit_code = 0
    @base_dir = Dir.pwd
    @logger = logger
    @debug = options[:debug]
    @config_file = ConfigFile.new(options[:config_file], logger)
    @action = options[:action]
    @execute_silently = options[:silent]
    @module_updates = options[:module_updates]
    @cmd_builder = CommandBuilder.new(options, @config_file, logger)
  end

  def execute_commands
    # Is the directory there?
    
    # Create a unique directory each time.
    working_dir = create_working_directory

    # Copy the source files into the running dir
    copy_files_to_working_directory(working_dir)

    # Create the remote state files.
    @logger.debug('move into the working dir')
    Dir.chdir working_dir
    # These are the commands that need to be run
    # Each method will handle the command that it needs to run.
    prompt_to_destroy if @action.downcase == 'destroy' && !@execute_silently
    run_commands
  end

  def create_working_directory
    # Create/Clean the working directory
    @logger.debug('Setup working directory')
    working_dir = File.expand_path(File.join(@base_dir, 'terraform-runner-working-dir'))

    FileUtils.rm_rf(working_dir) if Dir.exist?(working_dir)

    @logger.debug("Create directory #{working_dir}")
    make_working_dir(working_dir)
    working_dir
  end

  def copy_files_to_working_directory(working_dir)
    # Copy the Terraform code to the working directory
    sc_src = "#{File.expand_path(File.join(@base_dir, @config_file.tf_file_path))}/."
    @logger.debug("Ship souce code to #{working_dir}")
    FileUtils.cp_r(sc_src, working_dir, verbose: @debug)

    # Copy the modules to the working directory also if needed.
    if @config_file.local_modules['enabled']
      module_src = "#{File.expand_path(File.join(@base_dir, @config_file.local_modules['src_path']))}/."
      modules_dst = File.join(working_dir,@config_file.local_modules['dst_path'])
      @logger.debug("Ship modules to #{modules_dst}")
      FileUtils.cp_r(module_src, modules_dst, verbose: @debug)
    end
  end

  def make_working_dir(dir)
    @logger.info("Using directory: #{dir}")
    FileUtils.mkdir_p dir
  end

  def prompt_to_destroy
    puts %(Please type 'yes' to destroy your stack. Only yes will be accepted.)
    input = gets.chomp
    return if input == 'yes'
    puts "#{input} was not accepted. Exiting for safety!"
    exit 1
  end

  def run_commands
    cmd = OS.command
    # Running the commands depending on OS.
    # Linux allows us to use a Pessudo shell, This will stream the output
    # Windows has to execute in a subprocess and puts the STDOUT at the end.
    # This can lead to a long wait before seeing anything in the console.
    @logger.debug("Run the terraform state file command: #{@cmd_builder.tf_state_file_cmd}")
    cmd.run_command(@cmd_builder.tf_state_file_cmd)
    # Run the action specified
    @logger.debug("Run the terraform action command: #{@cmd_builder.tf_action_cmd}")
    # Build up the terraform action command
    @tf_exit_code = cmd.run_command(@cmd_builder.tf_action_cmd)
  end

  private :run_commands, :prompt_to_destroy, :make_working_dir, :copy_files_to_working_directory
  private :create_working_directory
end
