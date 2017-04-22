class CommentSerializer < ActiveModel::Serializer
  attributes :id, :text, :user_id

  # Model Relations
  belongs_to :issue
end
