require 'optparse'

module GitRank::Options
  def self.parse
    options = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: git-rank [options]"

      options[:exfile]  = []
      options[:exline]   = []
      options[:exauthor] = []
      options[:blame] = false
      options[:additions_only] = false
      options[:deletions_only] = false

      opts.on("-a", "--author [AUTHOR]", "Author breakdown by file") do |author|
        options[:author] ||= []
        options[:author] << author
      end

      opts.on("-e", "--exclude-author [EXCLUDE]", "Exclude authors") do |exauthor|
        options[:exauthor] << exauthor
      end

      opts.on("-b", "--blame", "Rank by blame of files not by git log") do
        options[:blame] = true
      end

      opts.on("-z", "--all-authors-breakdown", "All authors breakdown by file") do |author|
        options[:all_authors] ||= []
        options[:all_authors] << author
      end

      opts.on("-x", "--exclude-file [EXCLUDE]", "Exclude files or directories") do |exfile|
        options[:exfile] << exfile
      end

      opts.on("-y", "--exclude-line [EXCLUDE]", "Exclude lines matching a string") do |exline|
        options[:exline] << exline
      end

      opts.on("--additions-only", "Only count additions") do
        options[:additions_only] = true
      end

      opts.on("--deletions-only", "Only count deltions") do
        options[:deletions_only] = true
      end

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts

        puts <<-HEREDOC

        Examples:

        # Shows authors and how many lines they're
        # blamed for in all files in this directory
        git-rank

        # Shows file breakdown for all authors
        # and excludes files in a few directories
        git-rank -z -x spec/fixtures -x vendor

        # Shows file breakdown for just a few authors
        git-rank-contributors -a "Bob Johnson" -a prince
        HEREDOC
        exit
      end
    end.parse!
    options
  end
end
