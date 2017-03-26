class IssueSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :status
end
