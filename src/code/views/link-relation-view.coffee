{br, div, h2, label, span, input, p, i, select, option} = React.DOM

RelationFactory = require "../models/relation-factory"
SvgGraph        = React.createFactory require "./svg-graph-view"
tr              = require "../utils/translate"


Graph = React.createFactory React.createClass
  render: ->
    (div {className: 'graph'},
      (SvgGraph {
        width: 130
        height: 130
        yLabel: @props.yAxis
        xLabel: @props.xAxis
        formula: @props.formula
      })
    )

QuantStart = React.createFactory React.createClass
  render: ->
    start = tr "~NODE-RELATION-EDIT.SEMI_QUANT_START"
    (div {},
      (span {}, "#{tr "~NODE-RELATION-EDIT.AN_INCREASE_IN"} ")
      (span {className: "source"}, @props.source)
      (br {})
      (span {}, " #{tr "~NODE-RELATION-EDIT.CAUSES"} ")
      (span {className: "target"}, @props.target)
    )

module.exports = LinkRelationView = React.createClass

  displayName: 'LinkRelationView'

  getDefaultProps: ->
    link:
      targetNode:
        title: "default target node"
      sourceNode:
        title: "default source node"

  getInitialState: ->
    selectedVector: null

  componentWillReceiveProps: (newProps) ->
    if @props.link isnt newProps.link
      @setState
        selectedVector: null

  updateRelation: ->
    selectedVector = @getVector()
    selectedScalar = @getScalar()

    @setState {selectedVector}


    if selectedVector? and selectedScalar?
      relation = RelationFactory.fromSelections(selectedVector, selectedScalar)
      link = @props.link
      @props.graphStore.changeLink(link, {relation: relation})

  getVector: ->
    id = parseInt @refs.vector.value
    RelationFactory.vectors[id]

  getScalar: ->
    id = parseInt @refs.scalar.value
    RelationFactory.scalars[id]

  renderVectorPulldown: (increaseOrDecrease)->
    options = _.map RelationFactory.vectors, (opt, i) ->
      (option {value: opt.id, key: i}, opt.text)

    if not increaseOrDecrease?
      options.unshift (option {key: "placeholder", value: "unselected", disabled: "disabled"},
        tr "~NODE-RELATION-EDIT.UNSELECTED")
      currentOption = "unselected"
    else
      currentOption = increaseOrDecrease.id

    (div {className: "bb-select"},
      (span {}, "#{tr "~NODE-RELATION-EDIT.TO"} ")
      (select {value: currentOption, className:"", ref: "vector", onChange: @updateRelation},
      options)
    )

  renderScalarPulldown:(amount) ->
    options = _.map RelationFactory.scalars, (opt, i) ->
      (option {value: opt.id, key: i}, opt.text)

    if not amount?
      options.unshift (option {key: "placeholder", value: "unselected", disabled: "disabled"},
        tr "~NODE-RELATION-EDIT.UNSELECTED")
      currentOption = "unselected"
    else
      currentOption = amount.id

    disabled = "disabled" unless @state.selectedVector or amount?

    (div {className: "bb-select"},
      (span {}, "#{tr "~NODE-RELATION-EDIT.BY"} ")
      (select {value: currentOption, className:"", ref: "scalar", onChange: @updateRelation, disabled: disabled},
        options
      )
    )

  render: ->
    source = @props.link.sourceNode.title
    target = @props.link.targetNode.title
    {vector, scalar} = RelationFactory.selectionsFromRelation @props.link.relation
    vector ?= @state.selectedVector
    formula = @props.link.relation.formula
    (div {className: 'link-relation-view'},
      (div {className: 'top'},
        (QuantStart {source: source, target: target})
        (div {className: 'full'},
          @renderVectorPulldown(vector)
        )
        (div {className: 'full'},
          @renderScalarPulldown(scalar)
        )
      )
      (div {className: 'bottom'},
        (Graph {formula: formula, xAxis: source, yAxis: target})
      )
    )
