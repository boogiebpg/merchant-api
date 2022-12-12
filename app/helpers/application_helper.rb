# frozen_string_literal: true

module ApplicationHelper
  def display_messages(messages)
    return messages if messages.is_a?(String)

    messages.join('; ')
  end
end
