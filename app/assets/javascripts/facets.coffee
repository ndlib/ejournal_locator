jQuery ($) ->
  selected_categories = new Object

  $('#facets').find('div.blacklight-category_facet li').each ->
    li = $(this)
    selected = false
    selected_span = li.find('span.selected').first()
    if selected_span.length == 1
      count_span = selected_span.find('span.count')
      selected = true
      full_title = selected_span.text()
      # Strip the number of results from the end of the title
      full_title = full_title.replace(' '+count_span.text(),'')
      console.log(full_title)
    else
      link = li.find('a.facet_select').first()
      full_title = link.text()
    split_titles = full_title.split("/")
    parent_category = split_titles[0]
    subcategory = split_titles[1]
    # If length == 1, this is a parent category
    if !subcategory
      if selected
        selected_categories[parent_category] = true
    else
      li.addClass("child_facet")
      if link
        link.text(subcategory)
      else
        selected_span.text(subcategory + ' ')
        selected_span.append(count_span)
      if !selected_categories[parent_category]
        li.addClass("hide_facet")


