ComponentRegistry = require('../../src/circuit/ComponentRegistry.coffee')
CircuitComponent = require('../../src/circuit/circuitComponent.coffee')
Circuit = require('../../src/circuit/circuit.coffee')
CircuitNode = require('../../src/engine/circuitNode.coffee')
CircuitLoader = require('../../src/io/circuitLoader.coffee')
Util = require('../../src/util/util.coffee')
SimulationParams = require('../../src/core/SimulationParams.coffee')
Hint = require('../../src/engine/Hint.coffee')
Oscilloscope = require('../../src/scope/Oscilloscope.coffee')

fs = require 'fs'
_ = require('lodash')


describe "Simple Voltage Divider", ->
  before (done) ->
    voltdividesimple = JSON.parse(fs.readFileSync("./circuits/voltdividesimple.json"))
    @circuit = CircuitLoader.createCircuitFromJsonData(voltdividesimple)


#    CircuitLoader.createCircuitFromJsonFile "../../circuits/voltdividesimple.json", (circuit) =>
#      @circuit = circuit
    done()

  describe "should Analyze voltdividesimple.json and have", ->
    before (done) ->
      @circuit.Solver.reconstruct()
      @rowInfo = @circuit.Solver.circuitRowInfo
      done()

    it "7 elements", ->
      @circuit.numElements().should.equal 7

    it "valid origMatrix", ->
      @circuit.Solver.origMatrix.should.eql Util.zeroArray2(10, 10)

    it "valid origRightSide", ->
      @circuit.Solver.origRightSide.should.eql Util.zeroArray(10)

    it "valid circuitPermute", ->
      @circuit.Solver.circuitPermute.should.eql Util.zeroArray(10)

    it "valid circuitMatrix", ->
      @circuit.Solver.circuitMatrix.should.eql []

    it "valid right side", ->
      @circuit.Solver.circuitRightSide.should.eql []

    it "Circuit Solver should need map", ->
      @circuit.Solver.circuitNeedsMap.should.equal true

    it "has correct voltage sources", ->
      voltageSources = "VoltageElm,WireElm,WireElm,WireElm,WireElm"
      @circuit.getVoltageSources().toString().should.equal voltageSources

    describe "current rowInfos", ->

      it "index: 0", ->
        @rowInfo[0].toString().should.equal "RowInfo: type: 1, nodeEq: 0, mapCol: -1, mapRow: -1, value: 10, rsChanges: false, lsChanges: false, dropRow: true"

      it "index: 1", ->
        @rowInfo[1].toString().should.equal "RowInfo: type: 1, nodeEq: 0, mapCol: -1, mapRow: -1, value: 10, rsChanges: false, lsChanges: false, dropRow: true"

      it "index: 2", ->
        @rowInfo[2].toString().should.equal "RowInfo: type: 1, nodeEq: 0, mapCol: -1, mapRow: -1, value: 0, rsChanges: false, lsChanges: false, dropRow: true"

      it "index: 3", ->
        @rowInfo[3].toString().should.equal "RowInfo: type: 1, nodeEq: 0, mapCol: -1, mapRow: -1, value: 10, rsChanges: false, lsChanges: false, dropRow: true"

      it "index 4", ->
        @rowInfo[4].toString().should.equal "RowInfo: type: 1, nodeEq: 0, mapCol: -1, mapRow: -1, value: 0, rsChanges: false, lsChanges: false, dropRow: true"
#        @rowInfo[5].toString().should.equal "RowInfo: type: 1, nodeEq: 6, mapCol: -1, mapRow: -1, value: 0.0015, false false true"
#        @rowInfo[6].toString().should.equal "RowInfo: type: 1, nodeEq: 0, mapCol: -1, mapRow: -1, value: 0.0015, false false true"
#        @rowInfo[7].toString().should.equal "RowInfo: type: 1, nodeEq: 0, mapCol: -1, mapRow: -1, value: -0.0015, false false true"
#        @rowInfo[8].toString().should.equal "RowInfo: type: 1, nodeEq: 0, mapCol: -1, mapRow: -1, value: 0.0005, rsChanges: false, lsChanges: false, dropRow: true"
#        @rowInfo[9].toString().should.equal "RowInfo: type: 1, nodeEq: 0, mapCol: -1, mapRow: -1, value: -0.0005, rsChanges: false, lsChanges: false, dropRow: true"

    it "10 elements in circuitRowInfo", ->
      @circuit.Solver.circuitRowInfo.length.should.equal 10

    it "has correct nodes", ->
      @circuit.getNode(0).toString().should.equal "CircuitNode: 112 368 false [0 VoltageElm,0 WireElm]"
      @circuit.getNode(1).toString().should.equal "CircuitNode: 112 48 false [1 VoltageElm,0 WireElm]"
      @circuit.getNode(2).toString().should.equal "CircuitNode: 240 48 false [1 WireElm,0 ResistorElm,0 WireElm]"
      @circuit.getNode(3).toString().should.equal "CircuitNode: 240 368 false [1 ResistorElm,1 WireElm,0 WireElm]"
      @circuit.getNode(4).toString().should.equal "CircuitNode: 432 48 false [1 WireElm,0 ResistorElm]"
      @circuit.getNode(5).toString().should.equal "CircuitNode: 432 368 false [1 WireElm,1 ResistorElm]"

    it "has 6 nodes", ->
      @circuit.numNodes().should.equal 6

    it "should be linear", ->
      @circuit.Solver.circuitNonLinear.should.equal false


    describe "should runCircuit()", ->
      before ->
        @circuit.Solver.solveCircuit()
        @voltageCompnt = @circuit.getElmByIdx(0)
        @resistor10k = @circuit.getElmByIdx(2)
        @resistor20k = @circuit.getElmByIdx(6)

      it "has correct params", ->
        @circuit.inspect().should.eql([])

      describe "components have correct values", ->

        specify "Voltage Source has correct voltage", ->
          @voltageCompnt.volts.should.eql [0, 10]

        specify "Voltage Source has correct current", ->
          @voltageCompnt.current.should.eql 0.0015

        specify "10k Resistor has correct voltage", ->
          @resistor10k.volts.should.eql [10, 0]

        specify "10k Resistor has correct current", ->
          @resistor10k.current.should.equal 0.001

        specify "20k Resistor has correct voltage", ->
          @resistor20k.volts.should.eql [10, 0]

        specify "20k Resistor has correct current", ->
          @resistor20k.current.should.equal 0.0005

        it "0 bad nodes", ->
          @circuit.findBadNodes().length.should.equal 0


  describe "Running updateCircuit", ->
    before ->
      @circuit.updateCircuit()

    it "has correct voltage", ->
      @circuit.Solver.dump().should.eql ""
