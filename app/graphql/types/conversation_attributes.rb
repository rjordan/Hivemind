module Types
  class ConversationAttributes < Types::BaseInputObject
    description "Attributes for creating or updating a conversation"

    argument :title, String, required: true, description: "Title of the conversation"
    argument :description, String, required: false, description: "Description of the conversation"
    argument :persona_id, ID, required: true, description: "Which persona the users would like to portray"
    #    argument :participants, [ID], required: true, description: "IDs of the participants"
  end
end
