# app/views/mc_chat/index.json.jbuilder

json.(@person, :uuid, :first_name, :last_name, :is_volunteer)
json.address @person.location.try(:address_1)
json.state @person.location.try(:state)
json.zip @person.location.try(:zip_code)
json.local_legislators  @person.legislators
json.target_legislators @person.target_legislators(json: true)
json.address_required   @person.address_required?
