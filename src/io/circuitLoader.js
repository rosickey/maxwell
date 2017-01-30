let AntennaElm = require('../circuit/components/AntennaElm.js');
let WireElm = require('../circuit/components/WireElm.js');
let ResistorElm = require('../circuit/components/ResistorElm.js');
let GroundElm = require('../circuit/components/GroundElm.js');
let VoltageElm = require('../circuit/components/VoltageElm.js');
let DiodeElm = require('../circuit/components/DiodeElm.js');
let OutputElm = require('../circuit/components/OutputElm.js');
let SwitchElm = require('../circuit/components/SwitchElm.js');
let CapacitorElm = require('../circuit/components/CapacitorElm.js');
let InductorElm = require('../circuit/components/InductorElm.js');
let SparkGapElm = require('../circuit/components/SparkGapElm.js');
let CurrentElm = require('../circuit/components/CurrentElm.js');
let RailElm = require('../circuit/components/RailElm.js');
let MosfetElm = require('../circuit/components/MosfetElm.js');
let JfetElm = require('../circuit/components/JFetElm.js');
let TransistorElm = require('../circuit/components/TransistorElm.js');
let VarRailElm = require('../circuit/components/VarRailElm.js');
let OpAmpElm = require('../circuit/components/OpAmpElm.js');
let ZenerElm = require('../circuit/components/ZenerElm.js');
let Switch2Elm = require('../circuit/components/Switch2Elm.js');
let SweepElm = require('../circuit/components/SweepElm.js');
let TextElm = require('../circuit/components/TextElm.js');
let ProbeElm = require('../circuit/components/ProbeElm.js');

let AndGateElm = require('../circuit/components/AndGateElm.js');
let NandGateElm = require('../circuit/components/NandGateElm.js');
let OrGateElm = require('../circuit/components/OrGateElm.js');
let NorGateElm = require('../circuit/components/NorGateElm.js');
let XorGateElm = require('../circuit/components/XorGateElm.js');
let InverterElm = require('../circuit/components/InverterElm.js');

let LogicInputElm = require('../circuit/components/LogicInputElm.js');
let LogicOutputElm = require('../circuit/components/LogicOutputElm.js');
let AnalogSwitchElm = require('../circuit/components/AnalogSwitchElm.js');
let AnalogSwitch2Elm = require('../circuit/components/AnalogSwitch2Elm.js');
let MemristorElm = require('../circuit/components/MemristorElm.js');
let RelayElm = require('../circuit/components/RelayElm.js');
let TunnelDiodeElm = require('../circuit/components/TunnelDiodeElm.js');

let ScrElm = require('../circuit/components/SCRElm.js');
let TriodeElm = require('../circuit/components/TriodeElm.js');

let DecadeElm = require('../circuit/components/DecadeElm.js');
let LatchElm = require('../circuit/components/LatchElm.js');
let TimerElm = require('../circuit/components/TimerElm.js');
let JkFlipFlopElm = require('../circuit/components/JkFlipFlopElm.js');
let DFlipFlopElm = require('../circuit/components/DFlipFlopElm.js');
let CounterElm = require('../circuit/components/CounterElm.js');
let DacElm = require('../circuit/components/DacElm.js');
let AdcElm = require('../circuit/components/AdcElm.js');
let VcoElm = require('../circuit/components/VcoElm.js');
let PhaseCompElm = require('../circuit/components/PhaseCompElm.js');
let SevenSegElm = require('../circuit/components/SevenSegElm.js');
let CC2Elm = require('../circuit/components/CC2Elm.js');

let TransLineElm = require('../circuit/components/TransLineElm.js');

let TransformerElm = require('../circuit/components/TransformerElm.js');
let TappedTransformerElm = require('../circuit/components/TappedTransformerElm.js');

let LedElm = require('../circuit/components/LedElm.js');
let PotElm = require('../circuit/components/PotElm.js');
let ClockElm = require('../circuit/components/ClockElm.js');

let Scope = require('../circuit/Scope.js');

let SimulationParams = require('../core/simulationParams.js');

let Circuit = require('../circuit/circuit.js');
let Hint = require('../engine/hint.js');
let fs = require('fs');

let environment = require("../environment.js");

class CircuitLoader {
  static createEmptyCircuit() {
    let circuit = new Circuit();

    // Extract circuit simulation params
    let circuitParams = jsonData.shift();
    circuit.Params = new SimulationParams(circuitParams);
    circuit.flags = parseInt(circuitParams['flags']);
  }

  static createCircuitFromJsonData(jsonData) {
    // Create a defensive copy of jsonData
    jsonData = JSON.parse(JSON.stringify(jsonData));

    let circuit = new Circuit();

    // Extract circuit simulation params
    let circuitParams = jsonData.shift();
    circuit.Params = new SimulationParams(circuitParams);
    circuit.flags = parseInt(circuitParams['flags']);

    // Load each component from JSON data:
    for (let elementData of Array.from(jsonData)) {
      let type = elementData['name'];
      let ComponentClass = eval(type);

      if (!ComponentClass)
        circuit.error(`No matching component for ${type}`);

      if (!type)
        circuit.error(`Unrecognized Type ${type}`);

      else if (type === "Hint")
        circuit.setHint(elementData['hintType'], elementData['hintItem1'], elementData['hintItem2']);

      else if (type === "Scope")
        circuit.addScope(new Scope(elementData["pos"], elementData["params"]));

      else {
        let [x1, y1, x2, y2] = elementData['pos'];
        let flags = parseInt(elementData['flags']) || 0;

        circuit.solder(new ComponentClass(x1, y1, x2, y2, elementData['params'], parseInt(flags)));
      }
    }

    console.log(circuitParams);

    if (circuit.getElements().length === 0)
      console.error("No elements loaded. JSON most likely malformed");

    return circuit;
  }

  /**
    Constructs a circuit from a reference to a circuit JSON file.

   Example: CircuitLoader.createCircuitFromJsonFile("opint.json", function(circuit) { console.log(circuit); })
  */
  static createCircuitFromJsonFile(circuitFileName, onComplete=null) {
    if (environment.isBrowser) {
      return $.getJSON(circuitFileName, function(jsonData) {
        let circuit = CircuitLoader.createCircuitFromJsonData(jsonData);

        onComplete && onComplete(circuit);
      }).fail(function(e) {
        console.log( "Load error", e );

        let circuit = new Circuit();

        onComplete && onComplete(circuit);
      })
    } else {
     let jsonData = JSON.parse(fs.readFileSync(circuitFileName));
     return CircuitLoader.createCircuitFromJsonData(jsonData)
    }
  }
}

module.exports = CircuitLoader;

