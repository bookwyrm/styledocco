$ ->
  addPseudoClasses()

  $('#grid-settings').on 'submit', (ev) ->
    ev.preventDefault()
    $this = $(@)
    colCount = parseInt $this.find('#grid-col-count').val()
    colWidth = parseInt $this.find('#grid-col-width').val()
    gutterWidth = parseInt $this.find('#grid-gutter-width').val()
    addGridOverlay colCount, colWidth, gutterWidth

  $('#grid-hide').on 'click', (ev) ->
    ev.preventDefault()
    $('.styledocco-example-grid').remove()


add = (a, b) -> a + b

# Scans your stylesheet for pseudo classes and adds a class with the same name.
# Thanks to Knyle Style Sheets for the idea.
addPseudoClasses = ->
  # Compile regular expression.
  pseudos = [ 'link', 'visited', 'hover', 'active', 'focus', 'target',
              'enabled', 'disabled', 'checked' ]
  pseudoRe = new RegExp(":((" + pseudos.join(")|(") + "))", "gi")

  processedPseudoClasses = _.toArray(document.styleSheets)
    # Filter out `link` elements.
    .filter(
      (ss) ->
        not ss.href?
    ).map((ss) ->
      _.toArray(ss.cssRules)
      .filter((rule) ->
        # Keep only rules with pseudo classes.
        rule.selectorText and rule.selectorText.match pseudoRe
      ).map((rule) ->
        # Replace : with . and encoded :
        rule.cssText.replace pseudoRe, ".\\3A $1"
      ).reduce(add)
    ).reduce(add, '')

  if processedPseudoClasses.length
    # Add a new style element with the processed pseudo class styles.
    $('head').append $('<style />').text(processedPseudoClasses)


# Adds grid columns to example boxes.
addGridOverlay = (colCount = 9, colWidth = 60, gutterWidth = 20) ->
  $('.styledocco-example').forEach((el) ->
    $el = $(el)
    $grid = $('<div class="styledocco-example-grid" />')
    l = colCount
    while l--
      $grid.append $('<div class="styledocco-example-grid-line" />').css(
        'left': (colWidth + gutterWidth) * l
        width: gutterWidth
      )
    $existingGrid = $el.find('.styledocco-example-grid')
    if $existingGrid.length
      $existingGrid.replaceWith $grid
    else
      $el.append $grid
  )
