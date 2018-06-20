require "test_helper"

# Unit testing the DirectoryMonitor class requires a file system that knows
# about filenames and modification times.  The following class allows us to
# mock a simple file system; and, in the process, simulate implementations
# of the two class methods that are dependencies of the DirectoryMonitor.

class ErsatzFileSystem

  @@files = {}

  def self.touch(file)          # Creates and resets files.
    @@files[file] = Time.now
  end

  def self.ctime(filename)      # Simulates File::ctime()
    raise 'No such filename found' unless @@files[filename]
    @@files[filename]
  end

  def self.find(dir)            # Simulates Find::find()
    @@files.map { |filename, modtime| filename }.to_enum
  end

end

# Patch the DirectoryMonitor class to stub-out the call to Kernel::sleep().
# This allows the unit-tests to have synchronous control over DirectoryMonitor
# by letting us call resume on the DirectoryMonitor#on_change() fiber.

class DirectoryMonitor::DirectoryMonitor
  attr_reader :last_parameter
  def sleep(delay)
    @last_parameter = delay
    Fiber.yield
  end
end

class DirectoryMonitor_Base_TestCase < Minitest::Test

  private

    def setup_file_system
      %w{
        Abby.txt
        Billy.rb
        Cindy.rb
        Dan.dat
        Ellie.txt
        Frank.rb
        Gloria.txt
        Hank.dat
        Ira.rb.foo
        }.each { |f| ErsatzFileSystem.touch(f) }
    end

    def setup_watcher(suffix, loopflag = false, force = false)
      @dm = DirectoryMonitor::DirectoryMonitor.new(suffix)
      @dm.Find = ErsatzFileSystem  # Dependency injection for these unit tests
      @dm.File = ErsatzFileSystem
      @yield_history = []
      @dm_fiber = Fiber.new do
        @dm.on_change(loopflag, force) do |file_response|
          @yield_history << file_response
        end
      end
      @dm_fiber.resume
    end

    def run_watcher(*changed_files)
      changed_files.each{ |file| ErsatzFileSystem.touch(file) }
      @dm_fiber.resume
    end

end

class DirectoryMonitor_TestCase < DirectoryMonitor_Base_TestCase

  # Create the "object under test" with a simulated file system and its own
  # fiber for the on_change event.
  def setup
    setup_file_system
    setup_watcher("\\.rb|xyzzy")
  end

  def test_creation
    assert_instance_of(DirectoryMonitor::DirectoryMonitor, @dm)
    assert_equal(1, @dm.last_parameter, "Default delay should be 1 sec")
    assert_equal(0, @yield_history.length, "No yields should have happend")
  end

  def test_no_yields_without_file_changes
    run_watcher
    assert_equal(0, @yield_history.length)
  end

  def test_only_one_yield_per_set_of_changes
    run_watcher("Cindy.rb")
    assert_equal(1, @yield_history.length)
    run_watcher("Billy.rb", "Cindy.rb", "Dan.dat")
    assert_equal(2, @yield_history.length)
  end

  def test_change_one_watched_file
    run_watcher("Cindy.rb")
    assert_equal(1, @yield_history.length)
    assert_equal("Cindy.rb", @yield_history[0])
  end

  def test_change_two_watched_files
    run_watcher("Cindy.rb", "Frank.rb")
    assert_equal(1, @yield_history.length)
    assert_equal("Cindy.rb Frank.rb", @yield_history[0])
  end

  def test_no_yields_on_unwatched_file_change
    run_watcher("Dan.dat")
    assert_equal(0, @yield_history.length)
  end

  def test_yield_with_both_watched_and_unwatched_files
    run_watcher("Abby.txt", "Cindy.rb", "Dan.dat", "Frank.rb")
    assert_equal(1, @yield_history.length)
    assert_equal("Cindy.rb Frank.rb", @yield_history[0])
  end

  def test_regex_suffix_anchored_at_end_of_filename
    run_watcher("Abby.txt", "Billy.rb", "Helen.dat", "Ira.rb.foo")
    assert_equal(1, @yield_history.length)
    assert_equal("Billy.rb", @yield_history[0])
  end

end

class DirectoryMonitor_Looping_TestCase < DirectoryMonitor_Base_TestCase

  def setup
    setup_file_system
    setup_watcher("\\.rb|xyzzy", true)
  end

  def test_looping_yields_for_each_watched_file
    run_watcher("Abby.txt", "Cindy.rb", "Dan.dat", "Frank.rb")
    assert_equal(2, @yield_history.length)
    assert_equal("Cindy.rb", @yield_history[0])
    assert_equal("Frank.rb", @yield_history[1])
  end

end

class DirectoryMonitor_Force_TestCase # < DirectoryMonitor_Base_TestCase

  def setup
    setup_file_system
    setup_watcher("\\.rb|xyzzy", false, true)
  end

  def test_initial_forced_yields_all_watched_files
    run_watcher
    assert_equal(1, @yield_history.length)
    assert_equal("Billy.rb Cindy.rb Frank.rb", @yield_history[0])
  end

end

class DirectoryMonitor_Loop_And_Force_TestCase < DirectoryMonitor_Base_TestCase

  def setup
    setup_file_system
    setup_watcher("\\.rb|xyzzy", true, true)
  end

  def test_initial_forced_yields_all_watched_files
    run_watcher
    assert_equal(3, @yield_history.length)
    assert_equal("Billy.rb", @yield_history[0])
    assert_equal("Cindy.rb", @yield_history[1])
    assert_equal("Frank.rb", @yield_history[2])
  end

end

