#!/usr/bin/env rspec

require 'spec_helper'
require 'git-rank/options'

describe GitRank::Options do
  describe "parse" do
    let(:default_opts) {{ 
      :exauthor       => [],
      :exline         => [],
      :exfile         => [],
      :exauthor       => [],
    }}

    def silently(&block)
      warn_level = $VERBOSE
      $VERBOSE = nil
      result = block.call
      $VERBOSE = warn_level
      result
    end

    it "should error if it gets more than one argument" do
      silently { ARGV = ['foo', 'bar'] }
      expect { GitRank::Options.parse }.to raise_error(OptionParser::InvalidArgument, /Only one range/)
    end

    it "should turn a single argument into a range option" do
      silently { ARGV = ['foo'] }
      GitRank::Options.parse.should == default_opts.merge({:range => 'foo'})
    end
  end
end
