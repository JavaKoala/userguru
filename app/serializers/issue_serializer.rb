class IssueSerializer < ActiveModel::Serializer
  attributes :title, :description, :status
end
