jQuery ($) ->
  sidebar = $("#sidebar")
  bookmark_tools = sidebar.find(".tools")
  if bookmark_tools.length > 0 || sidebar.children().length == 0
    sidebar.hide()
    $("#main").addClass("no_sidebar")
