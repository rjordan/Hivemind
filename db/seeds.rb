# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


# Demo Data

user = User.find_or_create_by!(email: "rjordan01@gmail.com") do |user|
  user.username = "rjordan"
end

persona = Persona.find_or_create_by!(name: "Kent") do |persona|
  persona.user = user
  persona.default = true
  persona.description = "Kent is a seasoned software engineer with a passion for building scalable applications. He enjoys mentoring others and sharing his knowledge of best practices in software development."
end

character = Character.find_or_create_by!(name: "Seraphima") do |character|
  character.user = user
  character.tags = ["Fantasy", "Magic", "Adventure"]
end

conversation = Conversation.find_or_create_by!(title: "Seraphima's Journey") do |conversation|
  conversation.persona = persona
  conversation.tags = ["Fantasy", "Adventure"]
  conversation.scenario = "Seraphima embarks on a quest to find the lost city of Eldoria, facing magical creatures and ancient puzzles along the way."
  conversation.characters << character
end
