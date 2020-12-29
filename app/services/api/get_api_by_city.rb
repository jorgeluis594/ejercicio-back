require 'http'

class Api::GetApiByCity
  def call(city)
    data = get_data(city)
    create_hash_by_tour(format_data(data))
  end

  private

  def get_data(city)
    headers = {
      'Content-Type': 'application/vnd.api+json',
      'accept': 'application/vnd.api+json',
      'Authorization': 'Token eyJhbGciOiJIUzI1NiJ9.eyJyZXNlbGxlcl9lbWFpbCI6ImFwYWRpbGxhK3BydWViYWRldkB0dXJpc21vaS5jb20ifQ.ICmqJen12eyoyNfKlMoSkZG5yffULVVNBalbqztFxoU'
    }
    response = HTTP.headers(headers)
                   .get('https://api.turismoi.com/api/tours?page%5Bpage%5D=1&page%5Bper_page%5D=10')
    JSON.parse(response.to_s)
  end

  def format_data(data)
    activities_data = data['included'].each_with_object({}) do |activity, activities|
      activities[activity['id']] = activity['attributes']
    end

    data["data"].map do |tour|
      activities = tour["relationships"]["activities"]["data"].map { |activity| activities_data[activity["id"]] }
      tour["activities"] = activities
      tour
    end
  end

  def create_hash_by_tour(data)
    data.map do |tour|
      new_hash = {}
      avg_hours = tour['attributes']['avg_hours']
      new_hash[:name] = tour['attributes']['name']
      new_hash[:activities] = tour['activities'].map { |activity| activity['name'] }
      new_hash[:hours] = avg_hours != 24 ? avg_hours : null
      new_hash[:days] = tour['attributes']['days']
      new_hash[:price] = tour['attributes']['original_price']
      new_hash[:photo] = tour['attributes']['principal_photo']
      new_hash
    end
  end
end
