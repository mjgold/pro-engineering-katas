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
    it 'finds a user by email and last_name' do
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

  describe '#find' do
    it 'finds a user by id' do
      user = create_user
      id = user.read_attribute(:id)

      found_user = User.find(id)
      expect(found_user.read_attribute(:id)).to eq(user.read_attribute(:id))
    end

    it 'returns no results if there is no user with the passed id' do
      user_with_largest_id = User.all.max_by do |user|
        user.read_attribute(:id)
      end
      largest_id = user_with_largest_id.read_attribute(:id)

      found_user = User.find(largest_id + 1)
      expect(found_user).to eq(nil)
    end
  end

  describe '#create' do
    it 'creates a new user with specified attributes' do
      attributes = create_user_attributes
      user = User.create(attributes)

      # Not using User#where or #find to ensure #create is the only User method tested
      found_user = MiniRecord::Database.execute("SELECT * FROM users WHERE \
        last_name = '#{attributes[:last_name]}' AND email = '#{attributes[:email]}'")[0]
      expect(found_user["email"]).to eq(user[:email])
    end

    it 'fails to create a new user if a required attribute (last_name) is missing' do
      attributes = create_user_attributes
      attributes.delete(:last_name)

      expect {
        user = User.create(attributes).to raise SQlite3::ConstraintException
      }
    end
  end

  describe '#initialize' do
    it 'initializes a new user with specified attributes' do
      attributes = create_user_attributes
      user = User.new(attributes) # Calls initialize, which is private

      user.attribute_names.each do |attr_name|
        expect {
          user.attr_name.to eq(attributes[attr_name])
        }
      end
    end

    it 'fails when a required attribute (email) is missing' do
      attributes = create_user_attributes
      attributes.delete(:email)
      user = User.new(attributes) # Calls initialize, which is private

      user.attribute_names.each do |attr_name|
        expect {
          user.attr_name.not_to eq(attributes[attr_name])
        }
      end
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

def create_user_attributes
  {
    first_name: Faker::Name.first_name,
    last_name:  Faker::Name.last_name,
    email:      Faker::Internet.email,
    birth_date: Faker::Date.birthday,
    created_at: DateTime.now,
    updated_at: DateTime.now
  }
end
