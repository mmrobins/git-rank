#!/usr/bin/env rspec

require 'spec_helper'
require 'git-rank/blame'

describe GitRank::Blame do
  describe "when calculating rank" do
    let(:blame_foo_output) do <<-HEREDOC.gsub(/      /, '')
      da9ef7ea (Matt Robinson 2011-12-31 00:11:30 -0800 1) I'm changed!
      da9ef7ea (Matt Robinson 2011-12-31 00:11:30 -0800 2) I'm changed also!
      ^5047abc (Rob Mattinson 2011-12-31 00:10:06 -0800 3) delete me
      ^5047abc (Rob Mattinson 2011-12-31 00:10:06 -0800 4) delete me
      ^5047abc (Rob Mattinson 2011-12-31 00:10:06 -0800 4) delete me
      da9ef7ea (Matt Robinson 2011-12-31 00:11:30 -0800 6) I'm new
      da9ef7ea (Matt Robinson 2011-12-31 00:11:30 -0800 7) I'm new
      da9ef7ea (Matt Robinson 2011-12-31 00:11:30 -0800 8) I'm new
      da9ef7ea (Matt Robinson 2011-12-31 00:11:30 -0800 9) I'm new
      HEREDOC
    end

    let(:blame_bar_output) do <<-HEREDOC.gsub(/      /, '')
      ^5047abc (Matt Robinson 2011-12-31 00:10:06 -0800 1) change me
      ^5047abc (Matt Robinson 2011-12-31 00:10:06 -0800 2) change me as well
      HEREDOC
    end

    before do
      GitRank::Blame.expects(:get_files_to_blame).returns %w{foo bar}
      GitRank::Blame.expects(:blame).with('foo').returns(blame_foo_output)
      GitRank::Blame.expects(:blame).with('bar').returns(blame_bar_output)
    end

    it "should get correct line counts" do
      authors = GitRank::Blame.calculate
      authors.should == {
        "Matt Robinson"=> { 'foo' => 6, "bar" => 2 },
        "Rob Mattinson"=> { 'foo' => 3 }
      }
    end

    it "should exclude matching lines from the count" do
      authors = GitRank::Blame.calculate(:exline => ['new', 'as well'])
      authors.should == {
        "Matt Robinson"=> { 'foo' => 2, "bar" => 1 },
        "Rob Mattinson"=> { 'foo' => 3 }
      }
    end
  end
end
