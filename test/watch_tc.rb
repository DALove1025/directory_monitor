require "test_helper"

class Watch_Commandline_TestCase < MiniTest::Unit::TestCase

  private

    # Execute the "watch" script and capturing all output, both stdout and
    # stderr. Yields to the caller with the scripts output.
    def watch(*commands)
      commands.flatten.each do |command|
        yield (`ruby -Ilib bin/watch #{command} 2>&1`)
      end
    end

  public

    def test_options_version
      expected = "watch (#{DirectoryMonitor::VERSION})"
      watch("-v", "--version") do |actual_response|
        assert_equal(expected, actual_response.chomp)
      end
    end

end

