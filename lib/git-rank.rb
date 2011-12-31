#!/usr/bin/env ruby

require 'optparse'
require 'fileutils'
require 'yaml'
require 'digest/md5'

# from ptools https://github.com/djberg96/ptools/blob/master/lib/ptools.rb
class File
  def self.binary?(file)
    s = (File.read(file, File.stat(file).blksize) || "").split(//)
    ((s.size - s.grep(" ".."~").size) / s.size.to_f) > 0.30
  end
end

class Array
  def sum
    inject(:+)
  end
end

module GitRank
  class << self
  def parse_options
    options = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: git-rank-contributors-by-blame [options]"

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
        git-rank-contributors-by-blame

        # Shows file breakdown for all authors
        # and excludes files in a few directories
        git-rank-contributors-by-blame -z -x spec/fixtures -x vendor

        # Shows file breakdown for just a few authors
        git-rank-contributors-by-blame -a "Bob Johnson" -a prince
        HEREDOC
        exit
      end
    end.parse!
    options
  end

  def git_head_or_exit
    git_head = `git rev-parse HEAD`.chomp
    exit unless $?.exitstatus == 0
  end

  def save_cached_author_data(data, file)
    File.open(file, 'w') do |f|
      f.puts data.to_yaml
    end
  end

  def retrieve_cached_author_data(file)
    YAML::load( File.open(file) ) if File.exist? file
  end

  def calculate_rank(options)
    git_head = git_head_or_exit

    cached_data_dir = File.expand_path("~/.git_rank/#{git_head}")
    FileUtils.mkdir_p(cached_data_dir)

    # only count the options that affect line counts
    options_digest = Digest::MD5.hexdigest(options[:exline].to_s + options[:additions_only].to_s + options[:deletions_only].to_s)

    authors = Hash.new {|h, k| h[k] = h[k] = Hash.new(0)}

    if options[:blame]
      authors = retrieve_cached_author_data(cache_file) || authors
      return unless authors.empty?
      files = Dir.glob("**/*").reject { |f| !File.file? f or f =~ /\.git/ or File.binary? f }

      files.each do |file|
        lines = `git blame -w #{file}`

        puts "git blame failed on #{file}" unless $?.exitstatus == 0

        lines.each do |line|
          next if options[:exline].any? { |exline| line =~ /#{exline}/ }

          line =~ / \((.*?)\d/
          raise line unless $1
          authors[$1.strip][file] += 1
        end
      end
      save_cached_author_data(authors, cache_file)
    else
      cache_file = File.join(cached_data_dir, "log_" + options_digest)
      authors = retrieve_cached_author_data(cache_file) || authors
      return unless authors.empty?
      if options[:additions_only]
        regex = /^[\+]/
        words = "lines added"
      elsif options[:deletions_only]
        regex = /^[\-]/
        words = "lines deleted"
      else
        regex = /^[\+\-]/
        words = "lines of diff"
      end

      author = nil
      file = nil
      state = :pre_author
      `git log -M -C -C -p -w --no-color`.each do |line|
        case
        when (state == :pre_author || state == :post_author) && line =~ /Author: (.*)\s</
          author = $1
          state = :post_author
        when state == :post_author && line =~ /^\+\+\+ b\/(.*)/
          file = $1
          state = :in_diff
        when state == :in_diff && line =~ regex
          authors[author][file] += 1
        when state == :in_diff && line =~ /^commit /
          state = :pre_author
        end
      end
      save_cached_author_data(authors, cache_file)
    end
    authors
  end

  def delete_excluded_files(authors, excluded_files)
    authors.each do |author, line_counts|
      line_counts.each do |file, count|
        line_counts.delete(file) if excluded_files.any? {|ex| file =~ /^#{ex}/}
      end
    end
  end

  def print_author_breakdown(author_name, author_data, padding_size=nil)
    padding_size ||= author_name.size
    padding = ' ' * padding_size
    total = author_data.values.sum
    author_data.sort_by {|k, v| v }.each do |file, count|
      puts "#{padding} #{count} #{file}"
    end
    puts "#{author_name}#{' ' * (padding_size - author_name.size)} #{total}"
  end

  def print_rank(authors, options)
    authors = delete_excluded_files(authors, options[:exfile])
    if options[:author] and !options[:all_authors]
      options[:author].each do |author_name|
        puts "#{author_name} #{authors[author_name].values.sum}"

        print_author_breakdown(author_name, authors[author_name])
      end
    else
      authors.reject! {|k, v| options[:exauthor].include? k}

      max_author = authors.keys.max {|a,b| a.length <=> b.length }.length

      authors.sort_by {|k, v| v.values.sum }.each do |author, line_counts|
        padding = ' ' * (max_author - author.size)

        puts "#{author}#{padding} #{line_counts.values.sum}"

        if options[:all_authors]
          print_author_breakdown(author, line_counts, max_author)
        end
      end
    end
  end
  end
end
