class ChatsController < ApplicationController
  before_filter :authenticate!

  respond_to :json

  def receive
    toUser = QueueUser.find params[:to]
    logger.debug "#{current_user.username} sending message to #{toUser.username}"
    Juggernaut.publish "chats/#{toUser.token}", { :message => params[:message], :from => current_user.id }
    
    head :ok
  end
end
