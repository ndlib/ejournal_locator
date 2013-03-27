require 'spec_helper'

describe Journal do
  describe 'factory' do
    subject { FactoryGirl.create(:journal) }

    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe '#issn' do

  end
end
