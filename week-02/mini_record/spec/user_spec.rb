require 'bundler/setup'
require './mini_record.rb'
require './user.rb'
require 'rspec'
require 'faker'
require 'factory_girl'

MiniRecord::Database.database = 'test.db'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end

RSpec.describe User, type: :model do
  describe '#all' do
    it 'first delete all users' do
      MiniRecord::Database.execute('DELETE FROM users')
      expect(User.all.count).to eq(0)
    end

    it 'returns all users' do
      5.times do
        create_user
      end
      expect(User.all.count).to eq(5)
    end
  end

  describe '#where' do
    it 'finds a user by email' do
      user = create_user
      email = Faker::Internet.email
      last_name = Faker::Name.last_name
      user.write_attribute("email", email)
      user.write_attribute("last_name", last_name)
      user.save

      found_user = User.where("email == '#{email}' AND last_name == '#{last_name}'")[0]
      expect(found_user.read_attribute(:id)).to eq(user.read_attribute(:id))
    end
  end
end

def create_user
  User.create(
    first_name: Faker::Name.first_name,
    last_name:  Faker::Name.last_name,
    email:      Faker::Internet.email,
    birth_date: Faker::Date.birthday,
    created_at: DateTime.now,
    updated_at: DateTime.now
  )
end
