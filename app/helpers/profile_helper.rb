module ProfileHelper

  def news_feed(user, limit=10)
    feed = []
    # Get electricity reading data
    for reading in user.electricity_readings.find(:all, :limit => limit, :order => "taken_on DESC", :conditions => {:automatic => false})
      feed << {:image => 'electricity.png', 
               :when => reading.taken_on.to_time, 
               :text => "took a reading for '" + h(reading.electricity_account.name) + "'"}
    end
    # Get gas reading data
    for reading in user.gas_readings.find(:all, :limit => limit, :order => "taken_on DESC")
      feed << {:image => 'gas.png', 
               :when => reading.taken_on.to_time, 
               :text => "took a reading for '" + h(reading.gas_account.name) + "'"}
    end
    # Get fuel purchase data
    for purchase in user.vehicle_fuel_purchases.find(:all, :limit => limit, :order => "purchased_on DESC")
      feed << {:image => 'car.png', 
               :when => purchase.purchased_on.to_time, 
               :text => "bought some fuel for '" + h(purchase.vehicle.name) + "'"}
    end
    # Get completed action data
    for action in user.completed_actions.find(:all, :limit => limit, :order => "created_at DESC", :conditions => ["done = TRUE"])
      feed << {:image => 'action.png', 
               :when => action.created_at, 
               :text => "agreed to do the action " + link_to(h(action.action.title), :controller => "/actions", :action => 'view', :id => action.action.id)}
    end
    # Get friends data
    for friendship in user.approved_friendships.find(:all, :limit => limit, :order => "created_at DESC")
      feed << {:image => 'user.png', 
               :when => friendship.created_at, 
               :text => "made friends with " + (friendship.friend.public ? link_to(h(friendship.friend.name), :controller => "/profile", :login => friendship.friend.login) : h(friendship.friend.name))}
    end
    # Get groups data
    for group in user.group_memberships.find(:all, :limit => limit, :order => "created_at DESC")
      feed << {:image => 'group.png', 
               :when => group.created_at, 
               :text => "joined the group " + link_to(h(group.group.name), :controller => "/groups", :action => 'view', :id => group.group.id)}
    end
    # Get note data
    for note in user.all_notes(limit)
      feed << {:image => 'note.png', 
               :when => note.date.to_time,
               :text => "wrote a note: '" + h(note.note) + "'"}
    end
    # Get comment data
    for comment in user.authored_comments.find(:all, :limit => limit, :order => "created_at DESC", :conditions => ["NOT (commentable_type = 'User' AND commentable_id = ?)", user.id])
      case comment.commentable_type
      when "User" :
        name = comment.commentable == user ? "his" : comment.commentable.name + "'s"
        text = "wrote a comment on " + (comment.commentable.public ? link_to(h(name), :controller => "/profile", :login => comment.commentable.login, :anchor => "comment#{comment.id}") : h(name)) + " profile"
      when "Group" :
        text = "wrote a comment in the " + link_to(h(comment.commentable.name), :controller => "/groups", :action => 'view', :id => comment.commentable.id, :anchor => "comment#{comment.id}") + " group"
      end
      feed << {:image => 'comment.png', 
               :when => comment.created_at.to_time,
               :text => text}
    end
    # Get comment data
    for comment in user.comments.find(:all, :limit => limit, :order => "created_at DESC")
      text = ""
      if comment.user != user 
        text += (comment.user.public ? link_to(h(comment.user.name), :controller => "/profile", :login => comment.user.login) : h(comment.user.name)) + ' '
      end
      text += "wrote a "
      text += link_to('comment', :anchor => "comment#{comment.id}")
      text += " on this profile"
      feed << {:image => 'comment.png', 
               :when => comment.created_at.to_time,
               :text => text}
    end
    # Sort by date
    return feed.sort{ |x,y| y[:when] <=> x[:when] }.first(limit)
  end
  
end
