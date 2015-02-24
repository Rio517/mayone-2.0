require 'rails_helper'

describe District do
  describe "#fetch_rep" do
    let(:state) { FactoryGirl.create(:state, abbrev: 'CA') }
    let(:district) { FactoryGirl.create(:district, district: '13', state: state) }
    subject(:new_rep) { district.fetch_rep }

    it "associates rep with correct district" do
      expect(new_rep.district).to eq district
    end
  end
end