ModalDialog = React.createFactory require './modal-dialog-view'
TabbedPanel = React.createFactory require './tabbed-panel-view'

{div, ul, li, a} = React.DOM


module.exports = React.createClass

  displayName: 'ModalTabbedDialogView'

  render: ->
    (ModalDialog {title: @props.title, close: @props.close},
      (TabbedPanel {tabs: @props.tabs})
    )
