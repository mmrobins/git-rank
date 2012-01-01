#!/usr/bin/env ruby

require 'optparse'
require 'fileutils'
require 'yaml'
require 'digest/md5'
require 'git-rank/log'
require 'git-rank/blame'

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
  def calculate(options = {})
    authors = if options[:blame]
      GitRank::Blame.calculate(options)
    else
      GitRank::Log.calculate(options)
    end
    authors
  end

  end
end
