class Api::ConversationsController < ApplicationController

  def index
    # Base this off User in the future
    @conversations = Conversation.includes(:persona, :characters, :conversation_facts).all
    render json: @conversations, include: [:persona, :characters, :conversation_facts]
  end
end
