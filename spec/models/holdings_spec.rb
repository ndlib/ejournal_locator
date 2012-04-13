require 'spec_helper'

describe Holdings do
  describe "availability" do
    it "should parse 'Available from year. '" do
      holdings = Holdings.build_from_availability("Available from 1993. ")
      holdings.start_year.should == 1993
      holdings.end_year.should == Date.today.year
    end

    it "should parse 'Available from year until year. '" do
      holdings = Holdings.build_from_availability("Available from 1969 until 2004. ")
      holdings.start_year.should == 1969
      holdings.end_year.should == 2004
    end
  end
end
