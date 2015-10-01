Migrations          = require '../data/migrations/migrations'
DiagramNode         = require '../models/node'

module.exports = class MySystemImporter

  constructor: (@graphStore, @settings, @paletteStore) ->
    undefined

  importData: (data) ->
    Migrations.update(data)
    # Synchronous invocation of actions / w trigger
    @paletteStore.actions.loadData.trigger(data)
    @importNodes data.nodes
    @importLinks data.links
    @settings.importSettings data.settings
    @graphStore.setFilename data.filename or 'New Model'

  importNode: (nodeSpec) ->
    data = nodeSpec.data
    key = nodeSpec.key
    if data.paletteItem
      data.image = @paletteStore.store.findByUUID(data.paletteItem)?.image
    node = new DiagramNode(data, key)
    node

  importNodes: (importNodes) ->
    for nodespec in importNodes
      node = @importNode(nodespec)
      @graphStore.addNode node

  importLinks: (links) ->
    for link in links
      @graphStore.importLink link