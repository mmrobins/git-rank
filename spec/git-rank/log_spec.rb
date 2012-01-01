#!/usr/bin/env rspec

require 'spec_helper'
require 'git-rank/log'

describe GitRank::Log do
  describe "when calculating rank" do
    it "should get correct line counts" do
      log_output = File.open(File.join(FIXTURE_DIR, 'log_output')).read
      GitRank::Log.expects(:git_log).returns(log_output)

      authors = GitRank::Log.calculate
      authors.should == { "Matt Robinson"=> { 'foo' => 13, "bar" => 8 } }
    end
  end
end
