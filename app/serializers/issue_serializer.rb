class IssueSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :status

  # Model Relations
  has_many :comments
  belongs_to :user
end
