require "test_helper"
require "directory_monitor"

class DirectoryMonitor_TestCase < MiniTest::Unit::TestCase

  # See if we can successfully create the object.
  def test_creation
    obj = DirectoryMonitor::DirectoryMonitor.new
    assert_instance_of(DirectoryMonitor::DirectoryMonitor, obj)
  end

end

