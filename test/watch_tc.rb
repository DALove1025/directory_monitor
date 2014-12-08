require "test_helper"

class Watch_Commandline_TestCase < MiniTest::Unit::TestCase

  private

    def watch(command)
      yield (`ruby -Ilib bin/watch #{command} 2>&1`) 
    end

  public

    def test_version_options
      expected = "watch (#{DirectoryMonitor::VERSION})"
      watch("-v") { |result| assert_equal(expected, result.chomp) }
    end

end

