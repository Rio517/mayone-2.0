require 'rails_helper'

RSpec.describe V1::ActionsController, type: :controller do
  describe "POST create" do
    render_views
    context "with good params" do
      before do
        @activity = FactoryGirl.create(:activity, template_id: 'real_id')
        FactoryGirl.create(:activity)
        @person = FactoryGirl.create(:person, uuid: 'the-uuid')
      end
      it "returns person object" do
        expect(Person).to receive(:create_or_update).with(email: @person.email)
          .and_call_original
        post :create, person: { email: @person.email }, template_id: 'real_id'
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.slice('uuid', 'completed_activities').values)
          .to eq ['the-uuid', ['real_id']]
        activities = parsed_response['activities']
        expect(activities.count).to eq 2
        expect(activities.first.keys).to eq ['name', 'order', 'completed', 'template_id']
        expect(activities.map{|a| a['completed']}).to eq [true, false]
      end
      it 'processes source variables' do
        target_url = 'https://homepage.com'
        post :create, person: { email: @person.email }, template_id: 'real_id', source_url: target_url

        target_action = @person.actions.where(activity: @activity).last
        expect(target_action.source_url).to eq(target_url)
      end
    end
    context "with bad params" do
      it "returns error if person is missing" do
        post :create, template_id: 'real_id'
        expect(JSON.parse(response.body)['success']).to be_nil
        expect(JSON.parse(response.body)['error']).to eq 'person is required'
      end
      it "returns error if person is incomplete or template_id is bad" do
        post :create, person: { foo: 'bar' }, template_id: 'fake_id'
        expect(JSON.parse(response.body)['success']).to be_nil
        expect(JSON.parse(response.body)['error']).to eq "Person can't be blank. Activity can't be blank. Activity not found."
      end
      it "returns error if template_id is not provided" do
        post :create, person: { foo: 'bar' }
        expect(JSON.parse(response.body)['success']).to be_nil
        expect(JSON.parse(response.body)['error']).to eq "template_id is required"
      end
    end
  end
end
