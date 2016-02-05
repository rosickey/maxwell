CircuitComponent = require('../circuitComponent.coffee')
Settings = require('../../settings/settings.coffee')
Polygon = require('../../geom/polygon.coffee')
Rectangle = require('../../geom/rectangle.coffee')
Point = require('../../geom/point.coffee')

class InductorElm extends CircuitComponent
  @FLAG_BACK_EULER = 2

  @ParameterDefinitions = {
    "inductance": {
      name: "inductance"
      unit: "Henries"
      symbol: "H"
      default_value: 1e-3
      range: [-Infinity, Infinity]
      data_type: parseFloat
      type: "physical"
    },
    "current": {
      name: "current"
      unit: "Amperes"
      symbol: "A"
      default_value: 0
      range: [-Infinity, Infinity]
      data_type: parseFloat
      type: "physical"
    }
  }

  constructor: (xa, ya, xb, yb, params) ->
    @inductance = 0
    @nodes = new Array(2)
    @compResistance = 1e-3
    @current = 0
    @curSourceValue = 0

    super(xa, ya, xb, yb, params)


  stamp: (stamper) ->
    # Inductor companion model using trapezoidal or backward euler
    # approximations (Norton equivalent) consists of a current
    # source in parallel with a resistor.  Trapezoidal is more
    # accurate than backward euler but can cause oscillatory behavior.
    # The oscillation is a real problem in circuits with switches.
#      @nodes[0] = n0
#      @nodes[1] = n1

    ts = @getParentCircuit().timeStep()

    if @isTrapezoidal()
      @compResistance = 2 * @inductance / ts
    else
      @compResistance = @inductance / ts

    stamper.stampResistor @nodes[0], @nodes[1], @compResistance
    stamper.stampRightSide @nodes[0]
    stamper.stampRightSide @nodes[1]


  doStep: (stamper) ->
    stamper.stampCurrentSource @nodes[0], @nodes[1], @curSourceValue

  draw: (renderContext) ->
    @calcLeads 32

    @updateDots()

    v1 = @volts[0]
    v2 = @volts[1]
    hs = 8

    @setBboxPt @point1, @point2, hs
    renderContext.drawLeads(this)
    renderContext.drawCoil @lead1, @lead2, v1, v2, renderContext

    renderContext.drawValue 0, 0, this, @getUnitText(@inductance, "H")

    renderContext.drawDots(@point1, @point2, this)
    renderContext.drawPosts(this)

  getDumpType: ->
    "l"

  startIteration: ->
    if @isTrapezoidal()
      @curSourceValue = @getVoltageDiff() / @compResistance + @current
      # backward euler
    else
      @curSourceValue = @current

  nonLinear: ->
    false

  isTrapezoidal: ->
    true
#    (@flags & InductorElm.FLAG_BACK_EULER) is 0

  calculateCurrent: ->
    if @compResistance > 0
      @current = @getVoltageDiff() / @compResistance + @curSourceValue

    @current

  getInfo: (arr) ->
    arr[0] = "inductor"
    @getBasicInfo arr
    arr[3] = "L = " + @getUnitText(@inductance, "H")
    arr[4] = "P = " + @getUnitText(@getPower(), "W")

  reset: ->
    @current = 0
    @volts[0] = 0
    @volts[1] = 0
    @curcount = 0

  getVoltageDiff: ->
    @volts[0] - @volts[1]

  toString: ->
    "InductorElm"


module.exports = InductorElm
