require "test_helper"

class Watch_Commandline_TestCase < MiniTest::Test

  # We need a set of tests that run "out of process" in a way that let's us
  # both verify that the watch script executable is sort of working, as well
  # as to verify that --help, --version, and error conditions result in an
  # appropriate behavior the user will understand.

  # Note that since these tests are run "out of process" by using the system
  # command (back-tick style), that these test runs do generate input into
  # the code-coverage report. There aren't many, so it really makes little
  # difference.

  private

    # Execute the "watch" script and capture all output, both stdout and
    # stderr, and pass it to the caller with yield.
    def watch(*commands)
      commands.each do |command|
        yield (`ruby -Ilib bin/watch #{command} 2>&1`)
      end
    end

  public

    def test_no_command_provided
      watch("") do |response|
        assert_match("Error: shell command is required", response)
      end
    end

    def test_options_unknown
      watch("-x", "--xyzzy") do |response|
        assert_match("Error: unknown argument", response)
      end
    end

    def test_options_version
      watch("-v", "--version") do |response|
        assert_match("watch (#{DirectoryMonitor::VERSION})", response)
      end
    end

    def test_options_help
      watch("-h", "--help") do |response|
        assert_match("Synopsis", response)  # Spot check the help message.
        assert_match("Executes", response)
        assert_match("Usage", response)
        assert_match("Show this message", response)
      end
    end

end

