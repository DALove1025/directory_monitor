require "test_helper"
require "directory_monitor"

class Version_TestCase < MiniTest::Unit::TestCase

  # Detects mixed library versions. Which could happen, say, if an older
  # version of this gem is installed and the load-path's are confused.
  def test_version_up_to_date
    assert_equal('0.0.2', DirectoryMonitor::VERSION)
  end
  
end

