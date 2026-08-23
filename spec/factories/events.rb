FactoryBot.define do
  factory :event do
    sequence(:title) { |n| "Event #{n}" }
    date { 1.week.from_now }
    description { "A great event description" }
    image_link { "https://example.com/image.jpg" }
    sequence(:billetto_id) { |n| 1000000 + n }
  end
end
