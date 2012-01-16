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

    it "should error if it gets more than one argument" do
      ARGV = ['foo', 'bar']
      expect { GitRank::Options.parse }.to raise_error(OptionParser::InvalidArgument, /Only one range/)
    end

    it "should turn a single argument into a range option" do
      ARGV = ['foo']
      GitRank::Options.parse.should == default_opts.merge({:range => 'foo'})
    end
  end
end
