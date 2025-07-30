require 'faker'

# Admin user
User.create!(
  name: "Admin",
  email: "admin@example.com",
  password: "foobar",
  password_confirmation: "foobar",
  gender: "male",
  birthday: Date.new(1990, 1, 1),
  admin: true,
  activated: true,
  activated_at: Time.zone.now
)

# 30 random users
30.times do |n|
  name = Faker::Name.first_name[0...10] # cắt tối đa 10 ký tự
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  gender = %w[male female other].sample
  birthday = Faker::Date.between(from: 100.years.ago, to: Date.today)

  User.create!(
    name: name,
    email: email,
    password: password,
    password_confirmation: password,
    gender: gender,
    birthday: birthday,
    activated: true,
    activated_at: Time.zone.now
  )
end
