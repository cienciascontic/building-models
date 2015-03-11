var React       = require('react');
var Node        = require('./node-view');
var InfoPane    = require('./info-pane');
var Importer    = require('./importer');
var NodeList    = require('./models/link-manager');
var DiagramTookkit = require('./js_plumb_diagram_toolkit');
var $              = require('./vendor/touchpunch');
var _              = require('lodash');
log                = require('loglevel');


var LinkView = React.createClass({
  
  componentDidMount: function() {
    this._bindDiagramToolkit();
    this.linkManager = this.props.linkManager;
    this.linkManager.addLinkListener(this);
    this.linkManager.addNodeListener(this);
    var comp = this.getDOMNode();
    $(comp).find(".container").droppable({
      accept: '.proto-node',
      hoverClass: "ui-state-highlight",
      drop: this.addNode,
    });
  },

  addNode: function(event, ui) {
    var nodeData = ui.draggable.data();
    var offset = $(this.getDOMNode()).offset();
    var x = ui.offset.left - offset.left;
    var y = ui.offset.top - offset.top;
    var nodeProps = {
      x: x,
      y: y,
      title: nodeData.title,
      image: nodeData.image
    };
    var node = this.linkManager.importNode({data:nodeProps});
  },

  getInitialState: function() { 
    return {
      nodes: [],
      links: []
    }; 
  },

  componentWillUpdate: function() {
    if (this.diagramToolkit && this.diagramToolkit.clear) {
      this.diagramToolkit.clear();
    }
  },

  componentDidUpdate: function() {
    this._updateToolkit();
  },

  onNodeMoved: function(node_event) {
    if (this.ignoringEvents) { return; }
    var x = node_event.extra.position.left;
    var y = node_event.extra.position.top;
    this.linkManager.moveNode(node_event.nodeKey, x, y);
    return true;
  },

  onNodeDeleted: function(node_event) {
    if (this.ignoringEvents) { return; }
    this.linkManager.removeNode(node_event.nodeKey);
    return true;
  },

  handleConnect: function(info,evnt) {
    if (this.ignoringEvents) { return; }
    this.linkManager.newLinkFromEvent(info,evnt);
    return true;
  },

  handleClick: function(connection, evnt) {
    if (this.ignoringEvents) { return; }
    this.linkManager.selectLink(connection.linkModel);
  },

  handleLinkAdd: function(info,evnt) {
    var links = this.linkManager.getLinks();
    this.setState({links: links});
    return true;
  },

  handleLinkRm: function() {
    var links = this.linkManager.getLinks();
    this.setState({links: links});
  },

  handleNodeAdd: function(nodeData) {
    var nodes = this.linkManager.getNodes();
    this.setState({nodes: nodes});
    return true;
  },

  handleNodeMove: function(nodeData) {
    // TODO: PERF: we could look up the dom elem
    // for that node, and then just tell the
    // toolkit to repaint the links for that one elem...
    var nodes = this.linkManager.getNodes();
    this.setState({nodes: nodes});
    this.diagramToolkit.repaint();
    return true;
  },

  handleNodeRm: function() {
    var nodes = this.linkManager.getNodes();

    this.setState({nodes: nodes});
  },

  // TODO, can we get rid of this?
  _nodeForName: function(name) {
    if (!this.refs[name]) { 
      return false
    }
    return this.refs[name].getDOMNode();
  },

  _updateNodeValue: function(name, key, value) {
    var changed = 0;
    var nodes = this.state.nodes;
    this.state.nodes.forEach(function(node) {
      if(node.key == name) {
        node[key] = value;
        changed = changed + 1;
      }
    });

    if(changed > 0) {
      this.setState({nodes: nodes});
    }
  },

  _bindDiagramToolkit: function()   {
    var container = $(this.getDOMNode()).find(".container");
    var opts = {
      Container: container[0],
      handleConnect: this.handleConnect.bind(this),
      handleClick: this.handleClick.bind(this)
    };
    this.diagramToolkit = new DiagramTookkit(container, opts);
    this._updateToolkit();
  },

  _updateToolkit: function() {
    if(this.diagramToolkit) {
      this.ignoringEvents = true;
      this.diagramToolkit.supspendDrawing();
      this._redrawLinks();
      this._redrawTargets();
      this.diagramToolkit.resumeDrawing();
      this.ignoringEvents = false;
    }
  },

  _redrawTargets: function() {
    var targetSources = $(this.getDOMNode()).find(".elm");
    this.diagramToolkit.makeTarget(targetSources);
  },

  _redrawLinks: function() {
    var links = this.state.links;
    links.forEach(function(l) {
      // TODO move the operations bellow into Node class.

      var source         = this._nodeForName(l.sourceNode.key);
      var target         = this._nodeForName(l.targetNode.key);

      var label          = l.title;
      var color          = l.color;
      var sourceTerminal = (l.sourceTerminal == "a") ? "Top" : "Bottom";
      var targetTerminal = (l.targetTerminal == "a") ? "Top" : "Bottom";
      if (source && target) {
        this.diagramToolkit.addLink(source, target, label, color, sourceTerminal, targetTerminal, l);
      }
    }.bind(this));
  },



  render: function() {
    var moveHandler = this.onNodeMoved;
    var deleteHandler = this.onNodeDeleted;
    var linkManager = this.linkManager;
    var linkData = this.state.links;
    var nodeData = this.state.nodes;
    var nodes = this.state.nodes.map(function(node) {
      return (
        <Node 
          key={node.key} 
          data={node}
          selected = {node.selected}
          nodeKey={node.key}
          ref={node.key} 
          onMove={moveHandler}
          onDelete={deleteHandler}
          linkManager={linkManager}/>
      );
    });
    return (
      <div className="link-view">
        <div className="container">
          {nodes}
        </div>
      </div>
    );
  }
});


module.exports = LinkView;