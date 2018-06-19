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

      def pre_populate_hash(force_flag)
        find unless force_flag     # Skip, so all files appear changed.
      end

      def loop_forever(loopflag, cmd)
        loop do
          change_list = find_changed
#          change_list = [change_list.join(" ")] unless loopflag
          if ! loopflag
            change_list = [ change_list.join(" ") ]
          end
          change_list.each do |str|
            cmd.call str unless str == ""
          end
          find
          sleep(@delay)
        end
      end
            
    public

      attr_writer :Find, :File     # Used by the unit tests, see below.

      def initialize(suffix = '.*', delay = 1)
        @re, @delay = /(#{suffix})$/, delay
        @Find, @File = Find, File  # Dependency-injection hooks for unit-tests.
        @ctimes = {}
      end

      def on_change(loopflag = false, force = false, &cmd)
        # We expect an app using this infinite loop will be shutdown by a
        # signal or interrupt. We look for that, here. If client code needs
        # to cleanup, it should probably implement a trap("EXIT") handler.
        pre_populate_hash(force)
        begin
          loop_forever(loopflag, cmd)
        rescue SystemExit, Interrupt
          exit
        end
      end

  end

end

