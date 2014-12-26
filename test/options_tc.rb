require "test_helper"
require "directory_monitor/options"

class Optionse_TestCase < Minitest::Test

  private

    # We need a way to set the ARGV array, to spoof trollop, which means
    # redefining a constant. Doing that without generating a Ruby run-time
    # warning message is tricker than I expected. Here's the simplest way
    # I've come up with.
    def set_argv(*args)
      Object.send(:remove_const, "ARGV")
      Object.const_set("ARGV", args)
    end
   
  public

    def test_default_values
      set_argv("echo")
      opts = Options.parse
      assert_equal(".*",   opts[:suffix])
      assert_equal(5.0,    opts[:delay])
      assert_equal(false,  opts[:loop])
      assert_equal(false,  opts[:force])
      assert_equal("%%",   opts[:token])
      assert_equal(false,  opts[:verbose])
      assert_equal("echo", opts[:shell_command])
    end
    
    def test_suffix
      set_argv("-s", "\\.rb", "echo")
      assert_equal("\\.rb", Options.parse[:suffix])
      set_argv("--suffix", "\\.rb", "echo")
      assert_equal("\\.rb", Options.parse[:suffix])
    end

    def test_delay
      set_argv("-d", "12.3", "echo")
      assert_equal(12.3, Options.parse[:delay])
      set_argv("--delay", "12.3", "echo")
      assert_equal(12.3, Options.parse[:delay])
    end

    def test_loop
      set_argv("-l", "echo")
      assert_equal(true, Options.parse[:loop])
      set_argv("--loop", "echo")
      assert_equal(true, Options.parse[:loop])
    end

    def test_force
      set_argv("-f", "echo")
      assert_equal(true, Options.parse[:force])
      set_argv("--force", "echo")
      assert_equal(true, Options.parse[:force])
    end

    def test_token
      set_argv("-t", "FILE", "echo")
      assert_equal("FILE", Options.parse[:token])
      set_argv("--token", "FILE", "echo")
      assert_equal("FILE", Options.parse[:token])
    end

    def test_verbose
      set_argv("-V", "echo")
      assert_equal(true, Options.parse[:verbose])
      set_argv("--verbose", "echo")
      assert_equal(true, Options.parse[:verbose])
    end

end

