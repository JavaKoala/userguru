# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Create roles
user_roles = ["admin", "representative", "customer"]

user_roles.each do |role_name|
  Role.create(name: role_name)
end

# Create admin user
User.create!(name: "Admin User",
             email: "admin@user.guru",
             password: "password",
             password_confirmation: "password",
             activated: true)

# Create admin role for user
User.first.roles << Role.where(name: 'admin')

# Create issue for admin user
title       = "Example issue"
description = "This is an example issue"
User.first.issues.create!(title: title, description: description)

if Rails.env != 'production'
  99.times do |n|
    name = Faker::Name.name
    email = "example-#{n+1}@user.guru"
    password = "password"
    User.create!(name:  name,
                 email: email,
                 password:              password,
                 password_confirmation: password)
    user = User.find_by(email: email)
    user.roles << Role.where(name: 'customer')
  end
end
