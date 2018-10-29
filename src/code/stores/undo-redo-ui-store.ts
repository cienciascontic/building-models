/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

import { GraphStore } from "./graph-store";
import { Mixin } from "../mixins/components";
import { StoreUnsubscriber } from "./store-class";
const Reflux = require("reflux");

export const UndoRedoUIActions = Reflux.createActions(
  [
    "setCanUndoRedo"
  ]
);

export const UndoRedoUIStore = Reflux.createStore({
  listenables: [UndoRedoUIActions],

  init(context) {
    this.canUndo = false;
    return this.canRedo = false;
  },

  onSetCanUndoRedo(canUndo, canRedo) {
    this.canUndo = canUndo;
    this.canRedo = canRedo;
    return this.notifyChange();
  },

  notifyChange() {
    const data = {
      canUndo: this.canUndo,
      canRedo: this.canRedo
    };
    return this.trigger(data);
  }
});

export const UndoRedoUIMixin = {
  getInitialState() {
    return {
      canUndo: UndoRedoUIStore.canUndo,
      canRedo: UndoRedoUIStore.canRedo
    };
  },

  componentDidMount() {
    this.unsubscribe = UndoRedoUIStore.listen(this.onUndoRedoUIStateChange);
    // can't add listener in init due to order-of-initialization issues
    GraphStore.addChangeListener(this.onUndoRedoUIStateChange);
  },

  componentWillUnmount() {
    return this.unsubscribe();
  },

  onUndoRedoUIStateChange(state) {
    return this.setState({
      canUndo: state.canUndo,
      canRedo: state.canRedo
    });
  }
};

export interface UndoRedoUIMixin2Props {}

export interface UndoRedoUIMixin2State {
  canUndo: boolean;
  canRedo: boolean;
}

export class UndoRedoUIMixin2 extends Mixin<UndoRedoUIMixin2Props, UndoRedoUIMixin2State> {
  private unsubscribe: StoreUnsubscriber;

  public componentDidMount() {
    this.unsubscribe = UndoRedoUIStore.listen(this.handleUndoRedoUIStateChange);
    // can't add listener in init due to order-of-initialization issues
    GraphStore.addChangeListener(this.handleUndoRedoUIStateChange);
  }

  public componentWillUnmount() {
    return this.unsubscribe();
  }

  private handleUndoRedoUIStateChange = (state) => {
    return this.setState({
      canUndo: state.canUndo,
      canRedo: state.canRedo
    });
  }
}

UndoRedoUIMixin2.InitialState = {
  canUndo: UndoRedoUIStore.canUndo,
  canRedo: UndoRedoUIStore.canRedo
};
