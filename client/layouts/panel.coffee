Template.PanelLayout.rendered = ->
  # Start Sidebar Function
  $(".sidebar-left ul.sidebar-menu li a").click ->
    "use strict"
    $(".sidebar-left li").removeClass "active"
    $(this).closest("li").addClass "active"
    checkElement = $(this).next()
    if (checkElement.is("ul")) and (checkElement.is(":visible"))
      $(this).closest("li").removeClass "active"
      checkElement.slideUp "fast"
    if (checkElement.is("ul")) and (not checkElement.is(":visible"))
      $(".sidebar-left ul.sidebar-menu ul:visible").slideUp "fast"
      checkElement.slideDown "fast"
    if $(this).closest("li").find("ul").children().length is 0
      true
    else
      false

  if $(window).width() < 1025
    $(".sidebar-left").removeClass "sidebar-nicescroller"
    $(".sidebar-right").removeClass "sidebar-nicescroller"
    $(".nav-dropdown-content").removeClass "scroll-nav-dropdown"
  
  # End Sidebar Function
  
  # Start Button Toogle Function
  $(".btn-collapse-sidebar-left").click ->
    "use strict"
    $(".top-navbar").toggleClass "toggle"
    $(".sidebar-left").toggleClass "toggle"
    $(".page-content").toggleClass "toggle"
    $(".icon-dinamic").toggleClass "rotate-180"
    return

  $(".btn-collapse-sidebar-right").click ->
    "use strict"
    $(".top-navbar").toggleClass "toggle-left"
    $(".sidebar-left").toggleClass "toggle-left"
    $(".sidebar-right").toggleClass "toggle-left"
    $(".page-content").toggleClass "toggle-left"
    return

  $(".btn-collapse-nav").click ->
    "use strict"
    $(".icon-plus").toggleClass "rotate-45"
    return

  
  # End Button Toogle Function
  
  # Start Tooltip Function
  $(".tooltips").tooltip
    selector: "[data-toggle=tooltip]"
    container: "body"

  $(".popovers").popover
    selector: "[data-toggle=popover]"
    container: "body"

  $ ->
    "use strict"
    ###
    $(".scroll-chat-widget").slimScroll
      height: "200px"
      position: "right"
      size: "4px"
      railOpacity: 0.3
      railVisible: true
      alwaysVisible: true
      start: "bottom"
    ###

    return

  $(".chat-wrap").removeClass "scroll-chat-widget"  if $(window).width() < 768
  
  # End Nicescroll and Slimscroll Function
  
  # Start Panel Header Button Collapse
  $ ->
    "use strict"
    $(".collapse").on "show.bs.collapse", ->
      id = $(this).attr("id")
      $("button.to-collapse[data-target=\"#" + id + "\"]").html "<i class=\"fa fa-chevron-up\"></i>"
      return

    $(".collapse").on "hide.bs.collapse", ->
      id = $(this).attr("id")
      $("button.to-collapse[data-target=\"#" + id + "\"]").html "<i class=\"fa fa-chevron-down\"></i>"
      return

    $(".collapse").on "show.bs.collapse", ->
      id = $(this).attr("id")
      $("a.block-collapse[href=\"#" + id + "\"] span.right-icon").html "<i class=\"glyphicon glyphicon-minus icon-collapse\"></i>"
      return

    $(".collapse").on "hide.bs.collapse", ->
      id = $(this).attr("id")
      $("a.block-collapse[href=\"#" + id + "\"] span.right-icon").html "<i class=\"glyphicon glyphicon-plus icon-collapse\"></i>"
      return

    return

  
  # End Panel Header Button Collapse
  $(".btn").popover()
  return

