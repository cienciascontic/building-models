/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

// TODO: remove when modules are converted to TypeScript style modules
export {};

const PaletteInspectorView  = React.createFactory(require("./palette-inspector-view"));
const PaletteStore = require("../stores/palette-store");
const {div} = React.DOM;

module.exports = React.createClass({

  displayName: "NodeWell",

  mixins: [ PaletteStore.mixin ],

  getInitialState() {
    return {
      nodes: [],
      collapsed: true
    };
  },

  collapse() {
    return this.setState({collapsed: true});
  },

  expand() {
    return this.setState({collapsed: false});
  },

  toggle() {
    if (this.state.collapsed) {
      return this.expand();
    } else {
      return this.collapse();
    }
  },

  render() {
    let topNodePaletteClass    = "top-node-palette-wrapper";
    let topNodeTabPaletteClass = "top-node-palette-tab";
    if (this.state.collapsed) {
      topNodePaletteClass    = "top-node-palette-wrapper collapsed";
      topNodeTabPaletteClass = "top-node-palette-tab collapsed";
    }

    return (div({className: this.props.uiElements.nodePalette === false ? "wrapperwrapper hidden" : this.props.uiElements.globalNav === false ? "wrapperwrapper top" : "wrapperwrapper"},
      (div({className: topNodePaletteClass},
        (PaletteInspectorView({
          toggleImageBrowser: this.props.toggleImageBrowser,
          graphStore: this.props.graphStore
        }))
      )),
      (div({className: "tab-wrapper"},
        (div({className: topNodeTabPaletteClass, onClick: this.toggle}))
      ))
    ));
  }
});
