require 'http'

class Api::GetApiByCity
  def call(city)
    data = get_data(city.gsub(' ', ''))
    create_hash_by_tour(format_data(data))
  end

  private

  def get_data(city)
    uri = "https://api.turismoi.com/api/tours?page%5Bpage%5D=1&page%5Bper_page%5D=10&filter%5Bcities%5D=#{city}"
    headers = {
      'Content-Type': 'application/vnd.api+json',
      'accept': 'application/vnd.api+json',
      'Accept-Search-Filters': 'yes',
      'Authorization': Rails.application.credentials.api_token
    }
    response = HTTP.headers(headers).get(uri)
    JSON.parse(response.to_s)
  end

  def format_data(data)
    activities_data = data['included'].each_with_object({}) do |activity, activities|
      activities[activity['id']] = activity['attributes']
    end

    data['data'].map do |tour|
      activities = tour['relationships']['activities']['data'].map { |activity| activities_data[activity['id']] }
      tour['activities'] = activities
      tour
    end
  end

  def create_hash_by_tour(data)
    data.map do |tour|
      avg_hours = tour['attributes']['avg_hours']
      {
        name: tour['attributes']['name'],
        activities: tour['activities'].map { |activity| activity['name'] },
        hours: avg_hours != 24 ? avg_hours : nil,
        days: tour['attributes']['days'],
        price: tour['attributes']['original_price'],
        photo: tour['attributes']['principal_photo']
      }
    end
  end
end
