require "test_helper"

class Watch_Commandline_TestCase < MiniTest::Unit::TestCase

  private

    # Execute the "watch" script and capture all output, both stdout and
    # stderr, and pass it to the caller with yield.
    def watch(*commands)
      commands.flatten.each do |command|
        yield (`ruby -Ilib bin/watch #{command} 2>&1`)
      end
    end

  public

    def test_no_command_provided
      watch("") do |response|
        assert_match("Error: shell command is required", response)
      end
    end

   def test_shell_command
     watch("-D some shell command") do |response|
       assert_match("shell-command: some shell command", response)
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

    def test_options_suffix
      watch('-D -s "\.rb" echo', '-D --suffix="\.rb" echo') do |response|
        assert_match("suffix: \\.rb", response)
      end
    end

end

