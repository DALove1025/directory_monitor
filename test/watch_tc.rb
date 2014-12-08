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

    def test_options_default_values
      watch("-D echo") do |response|
        assert_match("delay: 5.0", response)
        assert_match("cascade: false", response)
        assert_match("loop: false", response)
        assert_match("force: false", response)
        assert_match("token: %%", response)
        assert_match("verbose: false", response)
      end
    end

    def test_options_delay
      watch("-D -d 12.3 echo", "-D --delay 12.3 echo", "-D --delay=12.3 echo") do |response|
        assert_match("delay: 12.3", response)
      end
    end

    def test_options_cascade
      watch("-D -c echo", "-D --cascade echo") do |response|
        assert_match("cascade: true", response)
      end
    end
    
    def test_options_loop
      watch("-D -l echo", "-D --loop echo") do |response|
        assert_match("loop: true", response)
      end
    end

    def test_options_force
      watch("-D -f echo", "-D --force echo") do |response|
        assert_match("force: true", response)
      end
    end

    def test_options_token
      watch("-D -t FILE echo", "-D --token FILE echo", "-D --token=FILE echo") do |response|
        assert_match("token: FILE", response)
      end
    end

    def test_options_verbose
      watch("-D -V echo", "-D --verbose echo") do |response|
        assert_match("verbose: true", response)
      end
    end

end

