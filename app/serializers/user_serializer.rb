class UserSerializer < ActiveModel::Serializer
  attributes :name, :email

  # Model Relations
  has_many :issues

end
