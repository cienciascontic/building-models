NodeInspectorView = React.createFactory require './node-inspector-view'
LinkInspectorView = React.createFactory require './link-inspector-view'
PaletteInspectorView = React.createFactory require './palette-inspector-view'
LinkValueInspectorView = React.createFactory require './link-value-inspector-view'
NodeValueInspectorView = React.createFactory require './node-value-inspector-view'
LinkRelationInspectorView = React.createFactory require './relation-inspector-view'
NodeRelationInspectorView = React.createFactory require './relation-inspector-view'

{div, i, span} = React.DOM

ToolButton = React.createFactory React.createClass
  displayName: 'toolButton'
  render: ->
    name = @props.name
    onClick = =>
      @props.onClick(@props.name) if @props.onClick

    classes = "icon-#{name} tool-button"
    classes = "#{classes} selected" if @props.selected
    classes = "#{classes} disabled" if @props.disabled
    (div {className: classes, onClick: onClick})

ToolPanel = React.createFactory React.createClass
  displayName: 'toolPanel'

  buttonData: [
      # {name: "plus",  simple: true, shows: "add", 'enabled': ['nothing','node','link'] }
      {name: "brush", simple: true, shows: "design",'enabled': ['node','link'] }
      {name: "ruler", simple: false, shows: "value", 'enabled': ['node'] }
      {name: "curve", simple: false, shows: "relations",'enabled': ['node']}
    ]

  isDisabled: (button) ->
    return false if _.includes(button.enabled, 'nothing')
    return false if _.includes(button.enabled, 'node') and @props.node
    return false if _.includes(button.enabled, 'link') and @props.link
    return true

  buttonProps: (button) ->
    props =
      name:     button.name
      shows:    button.shows
      selected: false
      disabled: @isDisabled(button)

    unless @isDisabled(button)
      props.onClick = =>
        @select button.name
      props.selected = @props.nowShowing is button.shows

    props

  select: (name) ->
    button = _.find @buttonData, {name: name}
    if button
      if @props.nowShowing isnt button.shows
        @props.onNowShowing(button.shows)
      else
        @props.onNowShowing(null)

  render: ->
    buttons = @buttonData.slice 0
    if @props.simplified
      buttons = _.filter buttons, (button) -> button.simple
    buttonsView = _.map buttons, (button) =>
      props = @buttonProps(button)
      (ToolButton props)

    (div {className: 'tool-panel'}, buttonsView)



module.exports = React.createClass

  displayName: 'InspectorPanelView'

  getInitialState: ->
    nowShowing: null

  setShowing: (item) ->
    @setState(nowShowing: item)


  renderPaletteInspector: ->
    (PaletteInspectorView {
      palette: @props.palette,
      toggleImageBrowser: @props.toggleImageBrowser,
      linkManager: @props.linkManager
    })

  renderDesignInspector: ->
    if @props.node
      (NodeInspectorView {
        node: @props.node
        onNodeChanged: @props.onNodeChanged
        onNodeDelete: @props.onNodeDelete
        palette: @props.palette
      })
    else if @props.link
      (LinkInspectorView {link: @props.link,  linkManager: @props.linkManager})

  renderValueInspector: ->
    if @props.node
      (NodeValueInspectorView {node: @props.node, linkManager: @props.linkManager})
    else if @props.link
      (LinkValueInspectorView {link:@props.link})

  renderRelationInspector: ->
    if @props.node
      (NodeRelationInspectorView {node:@props.node, linkManager: @props.linkManager})
    else if @props.link
      (LinkRelationInspectorView {link:@props.link, linkManager: @props.linkManager})


  renderInspectorPanel: ->
    view = switch @state.nowShowing
      when 'add'       then @renderPaletteInspector()
      when 'design'    then @renderDesignInspector()
      when 'value'     then @renderValueInspector()
      when 'relations' then @renderRelationInspector()

    (div {className: "inspector-panel-content"},
      view
    )

  render: ->
    className = "inspector-panel"
    unless @state.nowShowing
      className = "#{className} collapsed"

    (div {className: className},
      (ToolPanel
        node: @props.node
        link: @props.link
        nowShowing: @state.nowShowing
        onNowShowing: @setShowing
        simplified: @props.simplified
      )
      @renderInspectorPanel()
    )
