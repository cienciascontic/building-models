{input, div, i, img} = React.DOM
tr = require "../utils/translate"

NodeTitle = React.createFactory React.createClass
  displayName: "NodeTitle"
  maxTitleLength: 35
  getDefaultProps: ->
    defaultValue: tr "~NODE.UNTITLED"


  componentWillUnmount: ->
    if @props.isEditing
      @inputElm().off()

  componentDidUpdate: ->
    if @props.isEditing
      $elem =@inputElm()
      $elem.focus()

      $elem.off()
      enterKey = 13
      $elem.on "keyup", (e)=>
        if e.which is enterKey
          @finishEditing()

  inputElm: ->
    $(@refs.input.getDOMNode())

  inputValue: ->
    @inputElm().val()

  updateTitle: (e) ->
    newTitle = @inputValue()
    newTitle = newTitle.substr(0,@maxTitleLength)
    newTitle = if newTitle.length > 0 then newTitle else @props.defaultValue
    @props.onChange(newTitle)

  finishEditing: ->
    @updateTitle()
    @props.onStopEditing()

  renderTitle: ->
    (div {className: "node-title", onClick: @props.onStartEditing }, @props.title)

  renderTitleInput: ->
    displayValue = if @props.title is @props.defaultValue then "" else @props.title
    (input {
      type: "text"
      ref: "input"
      className: "node-title"
      onChange: @updateTitle
      value: displayValue
      maxlength: @maxTitleLength
      placeholder: @props.defaultValue
      onBlur: =>
        @finishEditing()
    })

  render: ->
    (div {className: 'node-title'},
      if @props.isEditing
        @renderTitleInput()
      else
        @renderTitle()
    )

module.exports = React.createClass

  displayName: "NodeView"

  componentDidMount: ->
    $elem = $(@refs.node.getDOMNode())
    $elem.draggable
      # grid: [ 10, 10 ]
      drag: @doMove
      stop: @doStop
      containment: "parent"

  getInitialState: ->
    editingNodeTitle: false

  handleSelected: (actually_select) ->
    if @props.linkManager
      selectionKey = if actually_select then @props.nodeKey else "dont-select-anything"
      @props.linkManager.selectNode selectionKey

  propTypes:
    onDelete: React.PropTypes.func
    onMove: React.PropTypes.func
    onSelect: React.PropTypes.func
    nodeKey: React.PropTypes.string

  getDefaultProps: ->
    onMove:   -> log.info "internal move handler"
    onStop:   -> log.info "internal move handler"
    onDelete: -> log.info "internal on-delete handler"
    onSelect: -> log.info "internal select handler"

  doMove: (evt, extra) ->
    @props.onMove
      nodeKey: @props.nodeKey
      reactComponent: this
      domElement: @refs.node.getDOMNode()
      syntheticEvent: evt
      extra: extra

  doStop: (evt, extra) ->
    @props.onMoveComplete
      nodeKey: @props.nodeKey
      reactComponent: this
      domElement: @refs.node.getDOMNode()
      syntheticEvent: evt
      extra: extra

  doDelete: (evt) ->
    @props.onDelete
      nodeKey: @props.nodeKey
      reactComponent: this
      domElement: @refs.node.getDOMNode()
      syntheticEvent: evt

  changeTitle: (newTitle) ->
    log.info "Title is changing to #{newTitle}"
    @props.linkManager.changeNodeWithKey(@props.nodeKey, {title:newTitle})

  startEditing: ->
    @props.linkManager.setNodeViewState(@props.data, 'is-editing')

  stopEditing: ->
    @props.linkManager.setNodeViewState(null, 'is-editing')

  isEditing: ->
    @props.linkManager.nodeViewState(@props.data, 'is-editing')

  render: ->
    style =
      top: @props.data.y
      left: @props.data.x
      "color": @props.data.color
    className = "elm"
    if @props.selected
      className = "#{className} selected"
    (div { className: className, ref: "node", style: style, "data-node-key": @props.nodeKey},
      (div {
        className: "img-background"
        onClick: (=> @handleSelected true)
        onTouchend: (=> @handleSelected true)
        },
        (div {className: "image-wrapper"},
          (if @props.data.image?.length > 0 and @props.data.image isnt "#remote" then (img {src: @props.data.image}) else null)
        )
        if @props.selected
          (div {className: "connection-source", "data-node-key": @props.nodeKey})
      )
      (NodeTitle {
        isEditing: @props.linkManager.nodeViewState(@props.data, 'is-editing')
        title: @props.data.title
        onChange: @changeTitle
        onStopEditing: @stopEditing
        onStartEditing: @startEditing

      })
    )

