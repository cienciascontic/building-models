import * as React from "react";
import { tr } from "../utils/translate";

/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

export const licenses = {
  map: {
    "public domain": {
      label: tr("~METADATA.LICENSE.PUBLIC_DOMAIN"),
      fullLabel: tr("~METADATA.LICENSE.PUBLIC_DOMAIN"),
      link: "http://en.wikipedia.org/wiki/Public_domain"
    },
    "pixabay": {
      label: "Pixabay",
      fullLabel: "Pixabay",
      link: "https://pixabay.com/service/license/"
    },
    "creative commons": {
      "cc by": {
        label: "Attribution Only",
        fullLabel: "Creative Commons: Attribution Only",
        link: "http://creativecommons.org/licenses/by/4.0"
      },
      "cc by-sa": {
        label: "ShareAlike",
        fullLabel: "Creative Commons: ShareAlike",
        link: "http://creativecommons.org/licenses/by-sa/4.0"
      },
      "cc by-nd": {
        label: "NoDerivatives",
        fullLabel: "Creative Commons: NoDerivatives",
        link: "http://creativecommons.org/licenses/by-nd/4.0"
      },
      "cc by-nc": {
        label: "NonCommercial (NC)",
        fullLabel: "Creative Commons: NonCommercial (NC)",
        link: "http://creativecommons.org/licenses/by-nc/4.0"
      },
      "cc by-nc-sa": {
        label: "NC-ShareAlike",
        fullLabel: "Creative Commons: NC-ShareAlike",
        link: "http://creativecommons.org/licenses/by-nc-sa/4.0"
      },
      "cc by-nc-nd": {
        label: "NC-NoDerivatives",
        fullLabel: "Creative Commons: NC-NoDerivatives",
        link: "http://creativecommons.org/licenses/by-nc-nd/4.0"
      }
    }
  },

  getLicense(slug) {
    return this.map[slug] || this.map["creative commons"][slug] || {label: "n/a", link: null};
  },

  getLicenseLabel(slug) {
    return (this.getLicense(slug)).label;
  },

  getRenderOptions(slug) {
    const licenses: JSX.Element[] = [];
    for (slug in this.map["creative commons"]) {
      const license = this.map["creative commons"][slug];
      licenses.push(<option key={slug} value={slug}>{license.label}</option>);
    }
    return [
      <option key={`${slug}-public-domain`} value="public domain">{this.getLicenseLabel("public domain")}</option>,
      <optgroup key={`${slug}-opt-group`} label="Creative Commons">
        {licenses}
      </optgroup>
    ];
  }
};
