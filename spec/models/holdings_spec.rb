require 'spec_helper'

describe Holdings do
  describe "availability" do
    it "should parse 'Available from [year]. '" do
      holdings = Holdings.build_from_availability("Available from 1993. ")
      holdings.start_year.should == 1993
      holdings.end_year.should == Date.today.year
    end

    it "should parse 'Available from [year] until [year]. '" do
      holdings = Holdings.build_from_availability("Available from 1969 until 2004. ")
      holdings.start_year.should == 1969
      holdings.end_year.should == 2004
    end

    it "should parse 'Available from [year] volume: [volume] issue: [issue]. '" do
      holdings = Holdings.build_from_availability("Available from 1917 volume: 1 issue: 1. ")
      holdings.start_year.should == 1917
      holdings.end_year.should == Date.today.year
    end

    it "should parse 'Available from [year] volume: [volume] issue: [issue] to [year] volume: [volume] issue: [issue]. '" do
      holdings = Holdings.build_from_availability("Available from 1995 volume: 1 issue: 1 until 1998 volume: 4 issue: 4. ")
      holdings.start_year.should == 1995
      holdings.end_year.should == 1998
    end

    it "should parse availability that contains volume information without an issue number." do
      holdings = Holdings.build_from_availability("Available from 1995 volume: 1 until 1998 volume: 4. ")
      holdings.start_year.should == 1995
      holdings.end_year.should == 1998
    end

    it "should parse availability that contains issue information without a volume number." do
      holdings = Holdings.build_from_availability("Available from 1995 issue: 48. ")
      holdings.start_year.should == 1995
      holdings.end_year.should == Date.today.year
    end
  end
end
