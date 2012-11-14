$ = jQuery

$ ->
  main_container = $("#main_container")
  folder_tools = main_container.find(".folderTools")
  if folder_tools.length > 0
    if $("#documents").find(".document").length <= 1
      main_container.find(".pageEntriesInfo").hide()
      main_container.find("#sortAndPerPage").hide()
