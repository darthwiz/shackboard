module CommentsHelper

  def comments_for(obj, options={})
    open = options[:open]
    html = link_to_remote("#{obj.comments.count} commenti", :url => blog_post_comments_path(obj), :method => :get)
    html << capture { render :partial => '/comments/comments_for', :locals => { :obj => obj } } if open
    content_tag(:div, html, :class => 'comments', :id => "comments_for_#{domid(obj)}")
  end

  def comment_item(comment)
    user        = comment.user
    can_edit    = comment.can_edit?(@user)
    author_html = content_tag(:div, [
      content_tag(:span, link_to(cleanup(user.username), user), :class => 'username'),
      user.avatar.blank? ? '' : image_tag(user.avatar, :class => 'avatar'),
    ].join(' '), :class => 'author')
    text_html = content_tag(:div, BbText.new(comment.text.to_s, Smiley.all(user)).to_html(:controller => self), :class => 'text')
    time_html = content_tag(:div, comment.created_at.strftime('%d/%m/%y, %H.%M'), :class => 'time')
    ops_html  = !can_edit ? '' : content_tag(:div, [
      link_to_remote('mod', :url => edit_comment_path(comment), :method => :get, :html => { :class => 'edit' }),
      link_to_remote('del', :url => comment_path(comment), :method => :delete, :html => { :class => 'delete' }, :confirm => "Vuoi veramente cancellare questo commento?"),
    ].join(' '), :class => 'operations')
    content_tag(:li, [ author_html, text_html, time_html, ops_html ].join("\n"), :class => "comment user_#{user.id}", :id => domid(comment))
  end

  def comment_editor(comment)
    content_tag(:li, :class => "comment user_#{comment.user_id}", :id => domid(comment)) do
      capture do
        remote_form_for(comment, :url => { :action => :update }) do |f|
          concat f.text_area(:text)
          concat f.submit('modifica')
        end
      end
    end
  end

end
