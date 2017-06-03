def dummy_logger
  logger = double
  allow(logger).to receive(:debug).and_return(true)
  allow(logger).to receive(:warn).and_return(true)
  logger
end

def dummy_ProcessStatus(exit_code)
  double('Process::Status', exitstatus: exit_code)
end

class PTY
end if OS.windows?
