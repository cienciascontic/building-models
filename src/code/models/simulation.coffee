scaleInput = (val, nodeIn, nodeOut) ->
  if (nodeIn.valueDefinedSemiQuantitatively isnt nodeOut.valueDefinedSemiQuantitatively)
    if (nodeIn.valueDefinedSemiQuantitatively)
      return nodeOut.mapSemiquantToQuant val
    else
      return nodeIn.mapQuantToSemiquant val
  else
    return val

RangeIntegrationFunction = (incrementAccumulators) ->

  # if we've already calculated a currentValue for ourselves this step, return it
  if @currentValue
    return @currentValue
  if @isAccumulator and not incrementAccumulators
    return @previousValue

  links = @inLinks('range')
  count = links.length
  nextValue = 0
  value = 0

  # if we have no incoming links, we always remain our previous or initial value
  if count < 1
    return @previousValue or @initialValue

  if @isAccumulator
    value = if @previousValue? then @previousValue else @initialValue            # start from our last value
    _.each links, (link) =>
      return unless link.relation.isDefined
      sourceNode = link.sourceNode
      inV = sourceNode.previousValue
      return unless inV               # we simply ignore nodes with no previous value
      outV = @previousValue or @initialValue

      inV = scaleInput(inV, sourceNode, this)

      # Here we set maxIn to zero because we want to substract inV when
      # we are in a `(maxIn - inV)` formula for accumulators (decreases by)
      # Need a better long-term solution for this.
      nextValue = link.relation.evaluate(inV, outV, 0)
      value += nextValue
  else
    _.each links, (link) =>
      if not link.relation.isDefined
        count--
        return
      sourceNode = link.sourceNode
      inV = if sourceNode.previousValue? then sourceNode.previousValue else sourceNode.initialValue
      inV = scaleInput(inV, sourceNode, this)
      outV = @previousValue or @initialValue
      nextValue = link.relation.evaluate(inV, outV, link.sourceNode.max, @max)
      value += nextValue
    if count >= 1
      value = value / count
    else
      value = @previousValue or @initialValue       # we had no defined inbound links

  # if we need to cap, do it at end of all calculations
  value = @filterFinalValue value

  value

SetAccumulatorValueFunction = (nodeValues) ->
  # get add, subtract and transfer links
  links = @inLinks('accumulator').concat(@inLinks('transfer'))
  return unless links.length > 0

  value = 0
  for link in links
    {sourceNode, relation, transferNode} = link
    inV = nodeValues[sourceNode.key]
    switch relation.type
      when 'accumulator'
        # TODO: check if outV is really equal to inV here - I'm not clear what outV is in this case'
        value += relation.evaluate(inV, inV, sourceNode.max, @max)

      when 'transfer'
        # TODO: check with Dan if the transfer value really is meant to be a percentage
        transferValue = nodeValues[transferNode.key]
        transferPercentage = transferValue / Math.max(transferNode.max, transferValue)
        for modifierLink in transferNode.inLinks('transfer-modifier')
          transferPercentage *= modifierLink.relation.evaluate(inV, inV, sourceNode.max, transferNode.max)

        finalTransferValue = inV * transferPercentage
        value += finalTransferValue
        # TODO: check with Dan if we take 1/100th of the value or 1/Math.pow(100,links.length)
        sourceValue = sourceNode.currentValue - (finalTransferValue / 100)
        sourceNode.currentValue = sourceNode.filterFinalValue sourceValue

  delta = value / Math.pow(100, links.length)
  # accumulators hold their values in previousValue which is confusing
  # (this done because the accumulator values is only computed on the first of the 20 loops in RangeIntegrationFunction)
  # TODO: possibly change RangeIntegrationFunction function to make this more clear
  @currentValue = @filterFinalValue @previousValue + delta

module.exports = class Simulation

  constructor: (@opts={}) ->
    @nodes          = @opts.nodes      or []
    @duration       = @opts.duration   or 10
    @capNodeValues  = @opts.capNodeValues or false
    @decorateNodes() # extend nodes with integration methods

    @onStart     = @opts.onStart or (nodeNames) ->
      log.info "simulation stated: #{nodeNames}"

    @onFrames    = @opts.onFrames or (frames) ->
      log.info "simulation frames: #{frames}"

    @onEnd       = @opts.onEnd or ->
      log.info "simulation end"

    @recalculateDesiredSteps = false
    @stopRun = false

  decorateNodes: ->
    _.each @nodes, (node) =>
      # make this a local node property (it may eventually be different per node)
      node.capNodeValues = @capNodeValues
      node.filterFinalValue = (value) => if @capNodeValues then Math.max(node.min, Math.min(node.max, value)) else value
      node._cumulativeValue = 0  # for averaging
      # Create a bound method on this node.
      # Put the functionality here rather than in the class "Node".
      # Keep all the logic for integration here in one file for clarity.
      node.getCurrentValue = RangeIntegrationFunction.bind(node)
      node.setAccumulatorValue = SetAccumulatorValueFunction.bind(node)

  initializeValues: (node) ->
    node.currentValue = null
    node.previousValue = null

  nextStep: (node) ->
    node.previousValue = node.currentValue
    node.currentValue = null

  evaluateNode: (node, firstTime) ->
    node.currentValue = node.getCurrentValue(firstTime)

  # create an object representation of the current timeStep and add
  # it to the current bundle of frames.
  generateFrame: (time) ->
    nodes = _.map @nodes, (node) ->
      title: node.title
      value: node.currentValue
    frame =
      time: time
      nodes: nodes

    @framesBundle.push frame

  stop: ->
    @stopRun = true


  run: ->
    @stopRun = false
    time = 0
    @framesBundle = []
    _.each @nodes, (node) => @initializeValues node

    nodeNames = _.pluck @nodes, 'title'
    @onStart(nodeNames)

    # For each step, we run the simulation many times, and then average the final few results.
    # We first run the simulation 10 times. This has the effect of "pushing" a value from
    # a parent node all the way down to all the descendants, while still allowing a simple
    # integration function on each node that only pulls values from immediate parents.
    # Note that this "pushing" may not do anything of value in a closed loop, as the values
    # will simply move around the circle.
    # We then run the simulation an additional 20 times, and the average the 20 results to
    # obtain a final value.
    # The number "20" used is arbitrary, but large enough not to affect loops the we expect
    # to see in Sage. In any loop, if the number of nodes in the loop and the number of times
    # we iterate are not dividible by each other, we'll see imbalances, but the effect of the
    # imbalance is smaller the more times we loop around.

    # Changes to accomodate data flows:
    #
    # There are now two types of nodes: normal and transfer and four types of links: range,
    # accumulator, transfer and transfer-modifier.  Transfer nodes are created automatically
    # between two accumulator nodes when the link type is set to transfer and are automatically
    # removed is the link is changed away from transfer or either of the nodes in the link
    # is changed from not being an accumulator.  Range links are the type of the original links -
    # they are pure functions that transmit a value from a source (domain) to a target (range) node
    # and are the only links evaluated during the 20 step cumulative value calculation.
    # Once each node's cummulative value obtained and then averaged across the nodes the accumulator
    # values are updated by checking the accumulator and transfer links into any accumulator node.
    # The transfer links values are then modified by the transfer-modifier links which are links
    # from the source node of a transfer link to the tranfer node of the transfer link.

    step = =>
      # push values down chain
      for i in [0...10]
        _.each @nodes, (node) => @nextStep node  # toggles previous / current val.
        _.each @nodes, (node) => @evaluateNode node, i is 0

      # accumulate values for later averaging
      for i in [0...20]
        _.each @nodes, (node) => @nextStep node
        _.each @nodes, (node) => node._cumulativeValue += @evaluateNode node

      # calculate average and capture the instantaneous node values
      nodeValues = {}
      _.each @nodes, (node) ->
        nodeValues[node.key] = node.currentValue = node._cumulativeValue / 20
        node._cumulativeValue = 0

      # set the accumulator values
      _.each @nodes, (node) ->
        if node.isAccumulator
          node.setAccumulatorValue nodeValues

      time++
      @generateFrame(time)


    while time < @duration
      step()
    @onFrames(@framesBundle)    # send all at once
    @onEnd()

