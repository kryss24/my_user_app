# spec/app_spec.rb
require 'rspec'
require 'httparty'
require 'json'

$cookies
RSpec.describe 'My Users App API' do
  base_url = 'http://localhost:8080'

  before(:all) do
    @age = 25
    @password = 'my_secret_password'
  end

  it 'should create a user via POST /users' do
    response = HTTParty.post("#{base_url}/users",
      headers: { 'Content-Type' => 'application/x-www-form-urlencoded', 'Accept' => 'application/json' },
      body: {
        firstname: 'firstname_from_httparty',
        lastname: 'lastname_from_httparty',
        age: @age,
        password: @password,
        email: 'from_httparty@matrix.org'
      }
    )
    expect(response.code).to eq(200)
    user_hash = JSON.parse(response.body)
    expect(user_hash['firstname']).to eq('firstname_from_httparty')
    expect(user_hash['lastname']).to eq('lastname_from_httparty')
    expect(user_hash['age']).to eq(@age)
    expect(user_hash['email']).to eq('from_httparty@matrix.org')
  end

  it 'should sign in a user via POST /sign_in' do
    response = HTTParty.post("#{base_url}/sign_in",
      headers: { 'Content-Type' => 'application/x-www-form-urlencoded', 'Accept' => 'application/json' },
      body: { email: 'from_httparty@matrix.org', password: @password }
    )
    expect(response.code).to eq(200)
    user_hash = JSON.parse(response.body)
    expect(user_hash['email']).to eq('from_httparty@matrix.org')
    $cookies = response.headers['set-cookie']
    
  end

  it 'should update password via PUT /users' do
    puts "Cookie récupéré après login: #{$cookies}"
    response = HTTParty.put("#{base_url}/users",
      headers: {
        'Cookie' => $cookies,
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Accept' => 'application/json'
      },
      body: { password: 'new_password' }
    )
    expect(response.code).to eq(200)
    user_hash = JSON.parse(response.body)
    expect(user_hash['firstname']).to eq('firstname_from_httparty')
  end

  it 'should delete user via DELETE /users' do
    response = HTTParty.delete("#{base_url}/users",
      headers: {
        'Cookie' => $cookies,
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Accept' => 'application/json'
      }
    )
    expect(response.code).to eq(204)

    # Check that user count decreased by one (assuming initial known number is 6)
    response = HTTParty.get("#{base_url}/users",
      headers: { 'Accept' => 'application/json' }
    )
    expect(response.code).to eq(200)
    users = JSON.parse(response.body)
    expect(users.count).to eq(5)
  end
end
