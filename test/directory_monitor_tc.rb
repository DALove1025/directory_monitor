require "test_helper"
require "directory_monitor"

# Unit testing the DirectoryMonitor class requires a file system that knows
# about filenames and modification times.  The following class allows us to
# model a simple file system; and, in the process, simulate implementations
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

class DirectoryMonitor_Base_TestCase < MiniTest::Unit::TestCase

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
        Hellen.dat
        Ira.rb.foo
        }.each { |f| ErsatzFileSystem.touch(f) }
    end
  
    def setup_watcher(suffix, loopflag = false, force = false, cascade = false)
      @dm = DirectoryMonitor::DirectoryMonitor.new(suffix)
      @dm.Find = ErsatzFileSystem
      @dm.File = ErsatzFileSystem
      @yield_history = []
      @dm_fiber = Fiber.new do
        @dm.on_change(loopflag, force, cascade) do |file_response|
          @yield_history << file_response
        end
      end
      @dm_fiber.resume
    end

    def run_watcher(changed_files = [])
      changed_files.each{ |f| ErsatzFileSystem.touch(f) }
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
    run_watcher(['Cindy.rb'])
    assert_equal(1, @yield_history.length, "Should be exactly 1 yield")
    run_watcher(['Cindy.rb', 'Dan.dat'])
    assert_equal(2, @yield_history.length, "Should be exactly 2 yields")
  end

  def test_change_one_file
    run_watcher(['Cindy.rb'])
    assert_equal(1, @yield_history.length[0], "Should be 1 file change")
    assert_equal('Cindy.rb', @yield_history[0][0], "Unexpected file name")
  end

  def test_change_two_files
    run_watcher(['Cindy.rb', 'Frank.rb'])
    assert_equal(2, @yield_history[0].length, "Multiple file changes failed")
    assert_equal('Cindy.rb', @yield_history[0][0], "Unexpected file name")
    assert_equal('Frank.rb', @yield_history[0][1], "Unexpected file name")
  end

  def test_no_yields_on_unwatched_file_changes
    run_watcher(['Dan.dat'])
    assert_equal(0, @yield_history.length, "Unexpected yield occured")
  end

  def test_yield_with_both_watched_and_unwatched_changes
    run_watcher(['Abby.txt', 'Cindy.rb', 'Dan.dat', 'Frank.rb'])
    assert_equal(1, @yield_history.length, 'Only 1 yield')
    assert_equal(2, @yield_history[0].length, 'Only 2 watched files')
    assert_equal('Cindy.rb', @yield_history[0][0], "Unexpected file name")
    assert_equal('Frank.rb', @yield_history[0][1], "Unexpected file name")
  end

  def test_regex_embeded_suffix
    run_watcher(['Abby.txt', 'Billy.rb', 'Helen.dat', 'Ira.rb.foo'])
    assert_equal(1, @yield_history.length, 'Only 1 yield')
    assert_equal(1, @yield_history[0].length, 'Only 1 watched file')
  end

end

class DirectoryMonitor_Looping_TestCase < DirectoryMonitor_Base_TestCase

  def setup
    setup_file_system
    setup_watcher("\\.rb|xyzzy", true)
  end

  def test_looping_yields_for_each_watched_file
    run_watcher(['Abby.txt', 'Cindy.rb', 'Dan.dat', 'Frank.rb'])
    assert_equal(2, @yield_history.length, 'Should yield twice for 2 files')
    assert_equal('Cindy.rb', @yield_history[0], "Unexpected file name")
    assert_equal('Frank.rb', @yield_history[1], "Unexpected file name")
  end
 
end

class DirectoryMonitor_Force_TestCase < DirectoryMonitor_Base_TestCase

  def setup
    setup_file_system
    setup_watcher("\\.rb|xyzzy", false, true)
  end

  def test_initial_forced_yields_all_watched_files
    run_watcher
    assert_equal(1, @yield_history.length, 'Only 1 yield expected')
    assert_equal('Billy.rb', @yield_history[0][0], "Unexpected file name")
    assert_equal('Cindy.rb', @yield_history[0][1], "Unexpected file name")
    assert_equal('Frank.rb', @yield_history[0][2], "Unexpected file name")
  end
 
end

