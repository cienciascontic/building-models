import * as React from "react";

import { AppSettingsMixinProps, AppSettingsMixinState, AppSettingsMixin } from "../stores/app-settings-store";
import { CodapMixinProps, CodapMixinState, CodapMixin } from "../stores/codap-store";
import { UndoRedoUIMixin, UndoRedoUIMixinProps, UndoRedoUIMixinState } from "../stores/undo-redo-ui-store";

import { AboutView } from "./about-view";
import { SimulationRunPanelView } from "./simulation-run-panel-view";
import { Mixer } from "../mixins/components";

import { CodapConnect } from "../models/codap-connect";

interface ToolButtonOptions {
  icon: string;
  label: string;
  labelStyle?: any;
  labelClassName?: string;
  onClick?: () => void;
  disabled?: boolean;
}

interface DocumentActionsViewOuterProps {
  graphStore: any; // TODO: get concrete type
  diagramOnly: boolean;
  standaloneMode: boolean;
}
type DocumentActionsViewProps = DocumentActionsViewOuterProps & CodapMixinProps & UndoRedoUIMixinProps & AppSettingsMixinProps;

interface DocumentActionsViewOuterState {
  selectedNodes: any[]; // TODO: get concrete type
  selectedLinks: any[]; // TODO: get concrete type
  selectedItems: any[]; // TODO: get concrete type
}
type DocumentActionsViewState = DocumentActionsViewOuterState & CodapMixinState & UndoRedoUIMixinState & AppSettingsMixinState;

export class DocumentActionsView extends Mixer<DocumentActionsViewProps, DocumentActionsViewState> {

  public static displayName = "DocumentActionsView";

  constructor(props: DocumentActionsViewProps) {
    super(props);
    this.mixins = [new CodapMixin(this, props), new UndoRedoUIMixin(this, props), new AppSettingsMixin(this, props)];
    const outerState: DocumentActionsViewOuterState = {
      selectedNodes: [],
      selectedLinks: [],
      selectedItems: []
    };
    this.setInitialState(outerState, CodapMixin.InitialState(), UndoRedoUIMixin.InitialState(), AppSettingsMixin.InitialState());
  }

  public componentDidMount() {
    // for mixins...
    super.componentDidMount();

    const deleteFunction = this.props.graphStore.deleteSelected.bind(this.props.graphStore);
    this.props.graphStore.selectionManager.addSelectionListener(manager => {
      const selectedNodes = manager.getNodeInspection() || [];
      const selectedLinks = manager.getLinkInspection() || [];

      this.setState({
        selectedNodes,
        selectedLinks,
        selectedItems: selectedNodes.concat(selectedLinks)
      });
    });
  }

  public render() {
    const showDeleteUI = !this.state.uiElements.inspectorPanel && (this.state.touchDevice || this.props.graphStore.usingLara);
    const buttonClass = (enabled) => { if (!enabled) { return "disabled"; } else { return ""; } };
    const showDeleteIcon = (showDeleteUI && this.state.lockdown && this.state.selectedLinks && (this.state.selectedLinks.length > 0)) || (showDeleteUI && !this.state.lockdown && this.state.selectedItems && (this.state.selectedItems.length > 0));
    return (
      <div className="document-actions">
        {this.props.standaloneMode ? this.renderCODAPToolbar() : undefined}
        <div className="misc-actions">
          {this.renderRunPanel()}
        </div>
        {!this.state.hideUndoRedo ?
          <div className="misc-actions toolbar">
            {showDeleteIcon
              ? this.renderToolbarButton({
                  icon: "icon-codap-trash",
                  label: "Delete",
                  onClick: this.handleDeleteClicked
                })
              : undefined}
            {this.renderToolbarButton({
              icon: "icon-codap-arrow-undo",
              label: "Undo",
              onClick: this.handleUndoClicked,
              disabled: !this.state.canUndo
            })}
            {this.renderToolbarButton({
              icon: `icon-codap-arrow-redo`,
              label: "Redo",
              onClick: this.handleRedoClicked,
              disabled: !this.state.canRedo
            })}
          </div> : undefined}
        <AboutView standaloneMode={this.props.standaloneMode}/>
      </div>
    );
  }

  private renderCODAPToolbar() {
    return (
      <div className="misc-actions toolbar">
        {this.renderToolbarButton({
          icon: "moonicon-icon-table",
          label: "Tables",
          labelStyle: {textDecoration: "line-through"}
        })}
        {this.renderToolbarButton({
          icon: "moonicon-icon-graph",
          label: "Graph",
          onClick: this.handleCODAPGraphToolClicked
        })}
        {this.renderToolbarButton({
          icon: "moonicon-icon-comment",
          label: "Text",
          onClick: this.handleCODAPTextToolClicked
        })}
      </div>
    );
  }

  private renderToolbarButton(options: ToolButtonOptions) {
    const {icon, label, labelStyle, labelClassName, onClick, disabled} = options;
    const className = `toolbar-button${disabled ? " disabled" : ""}`;
    return (
      <div className={className} onClick={onClick}>
        <div>
          <i className={icon} />
        </div>
        <div style={labelStyle} className={labelClassName}>{label}</div>
      </div>
    );
  }

  private renderRunPanel() {
    if (!this.props.diagramOnly) {
      return <SimulationRunPanelView />;
    }
  }

  private handleUndoClicked = () => {
    this.props.graphStore.undo();
  }

  private handleRedoClicked = () => {
    this.props.graphStore.redo();
  }

  private handleDeleteClicked = () => {
    if (this.state.lockdown) {
      // Only allow deletion of links in lockdown mode
      this.props.graphStore.removeSelectedLinks();
    } else {
      this.props.graphStore.deleteSelected();
    }
    // Clear stored selections after delete
    this.props.graphStore.selectionManager.clearSelection();
  }

  private handleCODAPGraphToolClicked = () => {
    const codapConnect = CodapConnect.instance("building-models");
    codapConnect.createEmptyGraph();
  }

  private handleCODAPTextToolClicked = () => {
    const codapConnect = CodapConnect.instance("building-models");
    codapConnect.createText();
  }
}
