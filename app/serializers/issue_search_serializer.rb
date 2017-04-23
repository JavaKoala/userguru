class IssueSearchSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :status

  # Model Relations
  belongs_to :user
end
