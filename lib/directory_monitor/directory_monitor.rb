# DirectoryMonitor -- a simple monitor class for detecting file changes in the
# current directory.
#
# A DirectoryMonitor object sleeps for a specified time and then looks in the
# current directory-tree for any changed files matching a particular RegEx.
# When file changes are discovered, the DirectoryMonitor yields to the caller
# with the pathnames of the changed files. After the yield returns, the
# DirectoryMonitor sleeps once again.
#
# File deletions are not detected.
#
# Examples:
#
#   Look every second for any differences and print the filenames, one on
#   each line...
#
#     DirectoryMonitor.new.on_change(true) { |file| puts file }
#
#   Check for new or changed Ruby files every 5 minutes...
#
#     DirectoryMonitor.new('\.rb', 300).on_change { puts "Some ruby changed" }
#
# Note that the suffix parameter to DirectoryMonitor#new is a RegEx, it is not
# a glob-style, filename wild-card.  For example, to watch only those files
# ending with, say, .dat, use a backslash escape, as in '\.dat', to force a
# match on a literal period character.

require 'find'

module DirectoryMonitor

  class DirectoryMonitor

    private

      def save_ctimes(files)
        files.each { |f| @ctimes[f] = @File.ctime(f) }
        files
      end

      def find_changed
        @Find.find('.').select { |f| f =~ @re && @ctimes[f] != @File.ctime(f) }
      end

      def find
        save_ctimes(find_changed)
      end

    public

      attr_writer :Find, :File     # Used by the unit tests, see below.

      def initialize(suffix = '.*', delay = 1)
        @re, @delay = /(#{suffix})$/, delay
        @Find, @File = Find, File  # Dependency-injection hooks for unit-tests.
        @ctimes = {}
      end

      def on_change(loopflag = false, force = false)  # loops forever.

        def prepopulate_hash(force_flag)
          find unless force_flag  # Skip, to force the first run.
        end

        prepopulate_hash(force)
        begin
          loop do
            (loopflag ? find : [ find.join(" ") ]).each do |str|
              yield str unless str == ""
            end
            # Now that we are done with all our yields, use find, one more time
            # to record all the current ctimes. Since we are done, we can safely
            # go back to sleep.
            find
            sleep(@delay)
          end
        rescue SystemExit, Interrupt
          # Since this is an infinite loop, we sort of expect that an app using
          # this class will be shut down by a signal or interrupt. So, to be a
          # bit more graceful, we detect these conditions and "go gently into
          # that good night." If the app needs to do any clean up, it should
          # probably implement a trap("EXIT") handler.
          exit
        end
      end

  end

end

