#!/usr/bin/env rspec

require 'spec_helper'
require 'git-rank/log'
require 'git-rank/blame'

describe GitRank do
  it "should default to calculating with git log" do
    GitRank::Log.expects(:calculate)
    GitRank.calculate
  end

  it "should calculate with git blame if the option is passed" do
    GitRank::Blame.expects(:calculate)
    GitRank.calculate(:blame => true)
  end
end
