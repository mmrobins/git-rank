#!/usr/bin/env rspec

require 'spec_helper'
require 'git-rank/printer'

describe GitRank::Printer do
  let(:author_info) { {
    "Matt Robinson" => { 'foo' => 1, 'bar' => 2, 'baz' => 10 },
    "Rob Mattinson" => { 'foo' => 3, 'bar' => 4 }
  } }

  it "should print authors reverse sorted by line count" do
    out = capture_stdout { GitRank::Printer.print(author_info) }
    out.should == <<-HEREDOC.gsub(/^      /, '')
      Rob Mattinson 7
      Matt Robinson 13
    HEREDOC
  end

  it "should print authors and files breakdown if all_authors options is true" do
    out = capture_stdout { GitRank::Printer.print(author_info, :all_authors => true) }
    out.should == <<-HEREDOC.gsub(/^      /, '')
      Rob Mattinson 7
                    3 foo
                    4 bar
      Rob Mattinson 7
      Matt Robinson 13
                    1 foo
                    2 bar
                    10 baz
      Matt Robinson 13
    HEREDOC
  end

  it "should print with specified files excluded by regex" do
    out = capture_stdout do
      GitRank::Printer.print(
        author_info,
        :exfile => [ 'fo*', 'ba[xyz]' ],
        :all_authors => true
      )
    end
    out.should == <<-HEREDOC.gsub(/^      /, '')
      Matt Robinson 2
                    2 bar
      Matt Robinson 2
      Rob Mattinson 4
                    4 bar
      Rob Mattinson 4
    HEREDOC
  end
end
