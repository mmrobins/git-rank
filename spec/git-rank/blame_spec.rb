#!/usr/bin/env rspec

require 'spec_helper'
require 'git-rank/blame'

describe GitRank::Blame do
  describe "when calculating rank" do
    it "should get correct line counts" do
      GitRank::Blame.expects(:get_files_to_blame).returns %w{foo bar}
      blame_foo_output = File.open(File.join(FIXTURE_DIR, 'blame_foo_output')).read
      blame_bar_output = File.open(File.join(FIXTURE_DIR, 'blame_bar_output')).read
      GitRank::Blame.expects(:blame).with('foo').returns(blame_foo_output)
      GitRank::Blame.expects(:blame).with('bar').returns(blame_bar_output)

      authors = GitRank::Blame.calculate
      authors.should == { "Matt Robinson"=> { 'foo' => 9, "bar" => 2 } }
    end
  end
end
