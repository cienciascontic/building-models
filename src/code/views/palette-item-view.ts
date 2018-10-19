/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

// TODO: remove when modules are converted to TypeScript style modules
export {}

const {div, img} = React.DOM;
const Draggable = require("../mixins/draggable");
const SquareImage = React.createFactory(require("./square-image-view"));
module.exports = React.createClass({

  displayName: "ProtoNode",

  mixins: [Draggable],

  onClick() {
    return this.props.onSelect(this.props.index);
  },

  removeClasses: ["palette-image"],

  render() {
    const className = "palette-image";
    const defaultImage = "img/nodes/blank.png";
    const imageUrl = (this.props.image != null ? this.props.image.length : undefined) > 0 ? this.props.image : defaultImage;

    return (div({
      "data-index": this.props.index,
      "data-title": this.props.node.title,
      "data-droptype": "paletteItem",
      className,
      ref: "node",
      onClick: this.onClick
    },

    (div({ className: "proto-node"},
      (div({className: "img-background"},
        (SquareImage({image: imageUrl}) ))
      // (img {src: imageUrl})
      )
    ))
    ));
  }
});