require 'spec_helper'

describe Holdings do
  describe "availability" do
    it "should parse 'Available from [year]. '" do
      holdings = Holdings.build_from_availability("Available from 1993. ")
      holdings.start_year.should == 1993
      holdings.end_year.should == Date.today.year
    end

    it "should parse availability without a space at the end" do
      holdings = Holdings.build_from_availability("Available from 1993.")
      holdings.start_year.should == 1993
      holdings.end_year.should == Date.today.year
    end

    it "should parse 'Available in [year]. '" do
      holdings = Holdings.build_from_availability("Available in 1998. ")
      holdings.start_year.should == 1998
      holdings.end_year.should == 1998
    end

    it "should parse 'Available until [year]. '" do
      holdings = Holdings.build_from_availability("Available until 1998. ")
      holdings.start_year.should == 0
      holdings.end_year.should == 1998
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

    it "should parse an issue number like '1/2'" do
      holdings = Holdings.build_from_availability("Available from 1993 volume: 17 issue: 1/2. ")
      holdings.start_year.should == 1993
      holdings.end_year.should == Date.today.year
    end

    it "should parse availability that mentions most recent years not being available." do 
      holdings = Holdings.build_from_availability("Available from 1965. Most recent 1 year(s) not available. ")
      holdings.start_year.should == 1965
      holdings.end_year.should == Date.today.year - 1
    end

    it "should parse availability that mentions most recent years and months not being available." do 
      holdings = Holdings.build_from_availability("Available from 2000. Most recent 2 year(s) 6 month(s) not available. ")
      holdings.start_year.should == 2000
      holdings.end_year.should == (Date.today - (2.years + 6.months)).year
    end

    it "should parse availability that mentions most recent months not being available." do 
      holdings = Holdings.build_from_availability("Available from 2001. Most recent 6 month(s) not available. ")
      holdings.start_year.should == 2001
      holdings.end_year.should == (Date.today - 6.months).year
    end

    it "should assume availability information if none is given" do
      holdings = Holdings.build_from_availability(nil)
      holdings.start_year.should == 0
      holdings.end_year.should == Date.today.year
    end

    it "should ignore extra spaces" do
      holdings = Holdings.build_from_availability("Available from 1995 volume: 21 issue: 1  until 2000 volume: 26 issue: 1. ")
      holdings.start_year.should == 1995
      holdings.end_year.should == 2000
    end

    it "should parse 'Most recent [number] year(s) available. '" do
      holdings = Holdings.build_from_availability("Most recent 2 year(s) available. ")
      holdings.start_year.should == Date.today.year - 2
      holdings.end_year.should == Date.today.year
    end

    it "should parse 'Most recent [number] month(s) available. '" do
      holdings = Holdings.build_from_availability("Most recent 6 month(s) available. ")
      holdings.start_year.should == (Date.today - 6.months).year
      holdings.end_year.should == Date.today.year
    end

    it "should parse 'Most recent [number] year(s) [number] month(s) available. '" do
      holdings = Holdings.build_from_availability("Most recent 2 year(s) 6 month(s) available. ")
      holdings.start_year.should == (Date.today - (2.years + 6.months)).year
      holdings.end_year.should == Date.today.year
    end

    it "should parse 'Most recent [number] year(s) not available. '" do
      holdings = Holdings.build_from_availability("Most recent 1 year(s) not available. ")
      holdings.start_year.should == 0
      holdings.end_year.should == Date.today.year - 1
    end

    it "should parse 'Most recent [number] year(s) [number] month(s) not available. '" do
      holdings = Holdings.build_from_availability("Most recent 2 year(s) 6 month(s) not available. ")
      holdings.start_year.should == 0
      holdings.end_year.should == (Date.today - (2.years + 6.months)).year
    end

    it "should parse 'Most recent [number] year(s) available. Most recent [number] year(s) not available. '" do
      holdings = Holdings.build_from_availability("Most recent 5 year(s) available. Most recent 2 year(s) not available. ")
      holdings.start_year.should == Date.today.year - 5
      holdings.end_year.should == Date.today.year - 2
    end
  end
end
