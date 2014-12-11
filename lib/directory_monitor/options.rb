# options.rb -- command-line options processing for the watch script.

require "trollop"

# Define the strings we display to the user for version identification and the
# help message.
ProgName = File.basename($PROGRAM_NAME, File.extname($PROGRAM_NAME)) 
Version = "#{ProgName} (#{DirectoryMonitor::VERSION})" 
Banner = <<-eos
  #{Version} -- Watch a directory for changes
  Synopsis
      Executes a shell-command when files change. If the shell-command contains
      a double-percent, %%, it is replaced with a space delimited list of path
      names for the changed files. When used with the --loop option, the shell-
      command is executed repeatedly, once for each changed file. In this case,
      %%, if present, is replaced with one path name at a time.

      The --suffix option limits the watched files to only those matching a
      regular expression, anchored at the end of the file name. Note that this
      is a RegEx, not a glob wildcard; therfore, to match a file name that
      contains a period, for example, .txt, the period must be escaped with a
      backslash. See the examples.

      File deletions are not detected.

  Examples
      watch -l -d 10 \"echo File %% has changed\"
      # Every 10 seconds, display each changed file on a separate line.
      
      watch -s "\\.rb|\\.yaml" rake
      # Every 5 seconds, run a rake task if any ruby or Yaml file changes.

  Usage
      #{ProgName} [-fhlvV] [-d <float>] [-st <str>] <shell-command>
eos

class Options

  # Use trollop to handle all our options switches and verify we have some
  # sort of shell-command specified on the command-line.
  def self.parse
    opts = Trollop::options do
      version "#{Version}"
      banner Banner.gsub(/^#{Banner[/^ +/, 0]}/, "")
      opt :suffix,  "Regex selecting the files being watched",  :default => ".*"
      opt :delay,   "Seconds to sleep between watches",         :default => 5.0
      opt :loop,    "Execute individual command for each file"
      opt :force,   "Force a first exectuion on all watched files"
      opt :token,   "String used for file name substitution",   :default => "%%"
      opt :verbose, "Print command on standard output",         :short => "V"
    end
    Trollop::die "shell command is required" if ARGV.empty?
    opts[:shell_command] = ARGV.join(" ")
    opts
  end

end

