/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const tr = require("./translate");

const units =
      {STEP: 1};
units.SECOND =  1;
units.MINUTE = 60 * units.SECOND;
units.HOUR   = 60 * units.MINUTE;
units.DAY    = 24 * units.HOUR;
units.WEEK   = 7 * units.DAY;
units.MONTH  = 30 * units.DAY;
units.YEAR   = 365 * units.DAY;

const toSeconds = (n, unit) => n * units[unit];

module.exports = {

  units: _.keys(units),

  defaultUnit: "STEP",

  defaultCollectorUnit: "STEP",

  toString(unit, plural) {
    const number = plural ? ".PLURAL" : "";
    return tr(`~TIME.${unit}${number}`);
  },

  stepsInTime(stepSize, stepUnit, period, periodUnit) {
    const stepSizeInSeconds = toSeconds(stepSize, stepUnit);
    const periodInSeconds   = toSeconds(period, periodUnit);
    return Math.floor(periodInSeconds / stepSizeInSeconds);
  }
};