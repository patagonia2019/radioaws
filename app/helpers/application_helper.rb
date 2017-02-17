module ApplicationHelper
  # Returns the full title on a per-page basis.
  def full_title(page_title = '')
    base_title = t("Application_Title")
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  def full_subtitle()
    subtitle = "Media Manzana 420 - (Rancho Grande) - Bariloche"
  end

  def sortable(column, title = nil)
    title ||= t(column)
    css_class = (column == sort_column) ? "current #{sort_direction}" : nil
    direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end

end
