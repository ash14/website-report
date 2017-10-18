module ApplicationHelper
  def flash_messages
    return '' if flash.empty?

    items = flash.map do |key, message|
      content_tag('li', message, class: key)
    end

    flash.clear

    content_tag('ul', items.join('').html_safe, id: 'flash-messages')
  end
end
