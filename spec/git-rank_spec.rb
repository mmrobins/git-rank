#!/usr/bin/env rspec

require 'spec_helper'

describe GitRank do
  describe "when calculating rank" do
    before do
      GitRank.stubs(:save_cached_author_data)
      GitRank.stubs(:retrieve_cached_author_data).returns nil
      GitRank.expects(:git_head_or_exit).returns 'abc123'
    end

    describe "by git log" do
      it "should get counts correct" do
        log_output = File.open(File.join(FIXTURE_DIR, 'log_output')).read
        GitRank.expects(:git_log).returns(log_output)

        authors = GitRank.calculate_rank
        authors.should == { "Matt Robinson"=> { 'foo' => 13, "bar" => 8 } }
      end
    end

    describe "by git blame" do
      it "should get counts correct" do
        GitRank.expects(:get_files_to_blame).returns %w{foo bar}
        blame_foo_output = File.open(File.join(FIXTURE_DIR, 'blame_foo_output')).read
        blame_bar_output = File.open(File.join(FIXTURE_DIR, 'blame_bar_output')).read
        GitRank.expects(:blame_file).with('foo').returns(blame_foo_output)
        GitRank.expects(:blame_file).with('bar').returns(blame_bar_output)

        authors = GitRank.calculate_rank(:blame => true)
        authors.should == { "Matt Robinson"=> { 'foo' => 9, "bar" => 2 } }
      end
    end
  end

  describe "when printing authors rank" do
    it "should print authors sorted by line count" do
      out = capture_stdout do
        GitRank.print_rank( { "Matt Robinson"=> { 'foo' => 13, "bar" => 8 } } )
      end
      out.should == "Matt Robinson 21\n"
    end
  end
end
