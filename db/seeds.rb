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
User.first.roles.create!(name: 'admin')
