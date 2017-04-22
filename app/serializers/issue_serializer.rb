class IssueSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :status

  # Model Relations
  has_many :comments
end
