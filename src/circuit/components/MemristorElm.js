let CircuitComponent = require("../circuitComponent.js");
let Util = require('../../util/util.js');
let Point = require('../../geom/point.js');

class MemristorElm extends CircuitComponent {
  static get Fields() {
  
    return {
      r_on: {
        name: "On resistance",
        data_type: parseFloat
  
      },
      r_off: {
        name: "Off resistance",
        data_type: parseFloat
      },
      dopeWidth: {
        name: "Doping Width",
        data_type: parseFloat
      },
      totalWidth: {
        name: "Total Width",
        data_type: parseFloat
      },
      mobility: {
        name: "Majority carrier mobility",
        data_type: parseFloat
      },
      resistance: {
        name: "Overall resistance",
        data_type: parseFloat,
        default_value: 100
      }
    };
  }

  constructor(xa, xb, ya, yb, params, f) {
    super(xa, xb, ya, yb, params, f);
  }


  getDumpType() {
    return "m";
  }

  setPoints() {
    super.setPoints(...arguments);
    this.calcLeads(32);
    this.ps3 = new Point();
    return this.ps4 = new Point();
  }

  reset() {
    return this.dopeWidth = 0;
  }

  nonLinear() {
    return true;
  }

  doStep(stamper) {
    return stamper.stampResistor(this.nodes[0], this.nodes[1], this.resistance);
  }

  stamp(stamper) {
    stamper.stampNonLinear(this.nodes[0]);
    return stamper.stampNonLinear(this.nodes[1]);
  }

  calculateCurrent() {
    return this.current = (this.volts[0] - this.volts[1]) / this.resistance;
  }

  startIteration() {
    let wd = this.dopeWidth / this.totalWidth;
    this.dopeWidth += (this.getParentCircuit().timeStep() * this.mobility * this.r_on * this.current) / this.totalWidth;

    if (this.dopeWidth < 0) {
      this.dopeWidth = 0;
    }
    if (this.dopeWidth > this.totalWidth) {
      this.dopeWidth = this.totalWidth;
    }

    return this.resistance = (this.r_on * wd) + (this.r_off * (1 - wd));
  }
}
MemristorElm.initClass();


module.exports = MemristorElm;
