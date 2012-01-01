#!/usr/bin/env rspec

require 'spec_helper'
require 'git-rank/printer'

describe GitRank::Printer do
  it "should print authors reverse sorted by line count" do
    out = capture_stdout do
      GitRank::Printer.print({
        "Matt Robinson" => { 'foo' => 1, 'bar' => 2, 'baz' => 10 },
        "Rob Mattinson" => { 'foo' => 3, 'bar' => 4 }
      })
    end
    out.should == <<-HEREDOC.gsub(/^      /, '')
      Rob Mattinson 7
      Matt Robinson 13
    HEREDOC
  end
end
