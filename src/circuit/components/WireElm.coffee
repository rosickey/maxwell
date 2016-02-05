CircuitComponent = require('../circuitComponent.coffee')
Settings = require('../../settings/settings.coffee')
Polygon = require('../../geom/polygon.coffee')
Rectangle = require('../../geom/rectangle.coffee')
Point = require('../../geom/point.coffee')

class WireElm extends CircuitComponent
  @FLAG_SHOWCURRENT: 1
  @FLAG_SHOWVOLTAGE: 2

  constructor: (xa, ya, xb, yb, params) ->
    super(xa, ya, xb, yb, params)

  toString: ->
    "WireElm"


  draw: (renderContext) ->
    @updateDots()

    renderContext.drawLinePt @point1, @point2, renderContext.getVoltageColor(@volts[0])
    @setBboxPt @point1, @point2, 3

    if @mustShowCurrent()
      s = @getUnitText(Math.abs(@getCurrent()), "A")
      @drawValues s, 4, renderContext
    else if @mustShowVoltage()
      s = @getUnitText(@volts[0], "V")

    renderContext.drawValue 10, 0, this, s
    renderContext.drawDots(@point1, @point2, this)
    renderContext.drawPosts(this)


  stamp: (stamper) ->
#    console.log("\n::Stamping WireElm::")
    stamper.stampVoltageSource @nodes[0], @nodes[1], @voltSource, 0

  mustShowCurrent: ->
    (@flags & WireElm.FLAG_SHOWCURRENT) isnt 0

  mustShowVoltage: ->
    (@flags & WireElm.FLAG_SHOWVOLTAGE) isnt 0

  getVoltageSourceCount: ->
    1

  getInfo: (arr) ->
    super()

    arr[0] = "Wire"
    arr[1] = "I = " + getUnitText(@getCurrent(), "A")
    arr[2] = "V = " + getVoltageText(@volts[0], "V")

  getDumpType: ->
    "w"

  getPower: ->
    0

  getVoltageDiff: ->
    @volts[0]

  isWire: ->
    true

  needsShortcut: ->
    true

module.exports = WireElm
