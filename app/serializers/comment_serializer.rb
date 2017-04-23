class CommentSerializer < ActiveModel::Serializer
  attributes :id, :text, :commenter_name, :commenter_email

  # Model Relations
  belongs_to :issue

  def commenter
    commenter_id = Comment.find_by(id: object.id).user_id
    user = User.find_by(id: commenter_id)
    commenter = { commenter_name: user.name, commenter_email: user.email }
  end

  def commenter_name
    commenter[:commenter_name]
  end

  def commenter_email
    commenter[:commenter_email]
  end
end
