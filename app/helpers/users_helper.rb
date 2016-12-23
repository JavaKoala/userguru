module UsersHelper

  def user_sortable(column, title = nil)
    title ||= column.titleize
    direction = column == sort_column(User.column_names, "name") && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}
  end

end
