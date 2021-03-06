import { tr } from "../utils/translate";

export interface Color {
  name: string;
  value: string;
}

export const Colors = {
  yellow: {
    name: tr("~COLOR.YELLOW"),
    value: "#f7be33"
  },
  darkBlue: {
    name: tr("~COLOR.DARK_BLUE"),
    value: "#105262"
  },
  medBlue: {
    name: tr("~COLOR.MED_BLUE"),
    value: "#72c0cc"
  },
  lightGray: {
    name: tr("~COLOR.LIGHT_GRAY"),
    value: "#aaa"
  },
  mediumGray: {
    name: tr("~COLOR.MED_GRAY"),
    value: "#787878"
  },
  mediumGrayInner: {
    name: tr("~COLOR.MED_GRAY"),
    value: "#aaaa"
  },
  darkGray: {
    name: tr("~COLOR.DARK_GRAY"),
    value: "#444"
  },
  data: {
    name: tr("~COLOR.DATA"),
    value: "#e99373"
  },
  dataInner: {
    name: tr("~COLOR.DATA"),
    value: "#f1c6b6aa"
  }
};

export const ColorChoices = [Colors.yellow, Colors.darkBlue, Colors.medBlue];
