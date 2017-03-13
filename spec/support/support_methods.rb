def dummy_logger
  logger = double
  allow(logger).to receive(:debug).and_return(true)
  allow(logger).to receive(:warn).and_return(true)
  return logger
end

def dummy_PTY
  PTY
end

def dummy_ProcessStatus(exit_code)
  double('Process::Status', exitstatus: exit_code)
end

class PTY
end
