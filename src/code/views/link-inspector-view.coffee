{div, h2, button, label, input} = React.DOM
tr = require "../utils/translate"

palettes = [
  ['#4D6A6D','#798478', "#A0A083", "#C9ADA1", "#EAE0CC"],
  ['#351431','#775253', "#BDC696", "#D1D3C4", "#DFE0DC"],
  ['#D6F49D','#EAD637', "#CBA328", "#230C0F", "#A2D3C2"]
]
palette = palettes[2]

module.exports = React.createClass

  displayName: 'LinkEditView'

  notifyChange: (title, color, deleted) ->
    @props.onLinkChanged? @props.link, title, color, !!deleted

  changeTitle: (e) ->
    @notifyChange e.target.value, @props.link.color

  deleteLink: ->
    @notifyChange @props.link.title, @props.link.color, true

  pickColor: (e) ->
    @notifyChange @props.link.title, $(e.target).css('background-color')

  render: ->
    tabs = [tr('design'), tr('define')]
    selected = tr('design')
    (div {className: 'link-inspector-view'},
      # Previous design comps
      # (InspectorTabs {tabs: tabs, selected: selected} )
      (div {className: 'inspector-content'},
        (div {className: 'edit-row'},
          (label {name: 'title'}, tr "~LINK-EDIT.TITLE")
          (input {type: 'text', name: 'title', value: @props.link.title, onChange: @changeTitle})
        )
        (div {className: 'edit-row'},
          (label {className: 'link-delete', onClick: @deleteLink}, tr("~LINK-EDIT.DELETE"))
        )
      )
    )
