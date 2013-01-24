# <DEFINE>
define [
  'cs!Settings',
  'cs!DrawHelper',
  'cs!Polygon',
  'cs!Rectangle',
  'cs!Point',
  'cs!CircuitComponent',
  'cs!Units'
], (
  Settings,
  DrawHelper,
  Polygon,
  Rectangle,
  Point,

  CircuitComponent,
  Units
) ->
# </DEFINE>


  class GroundElm extends CircuitComponent

    constructor: (xa, ya, xb, yb, f, st) ->
      super xa, ya, xb, yb, f, st
  
    getDumpType: ->
      "g"
  
    getPostCount: ->
      1
  
    draw: (renderContext) ->
      color = DrawHelper.getVoltageColor(0)
      @doDots(renderContext)
      renderContext.drawThickLinePt @point1, @point2, color
  
      for row in [0...3]
        startPt = 10 - row * 2
        endPt = row * 3
        DrawHelper.interpPoint @point1, @point2, 1 + endPt / @dn, startPt, DrawHelper.ps1, DrawHelper.ps2
        renderContext.drawThickLinePt DrawHelper.ps1, DrawHelper.ps2, color
  
      DrawHelper.interpPoint @point1, @point2, DrawHelper.ps2, 1 + 11.0 / @dn
      @setBboxPt @point1, DrawHelper.ps2, 11
      @drawPost @x1, @y1, @nodes[0], renderContext
  
    setCurrent: (x, currentVal) ->
      @current = -currentVal
  
    stamp: (stamper) ->
      stamper.stampVoltageSource 0, @nodes[0], @voltSource, 0
  
    getVoltageDiff: ->
      0
  
    getVoltageSourceCount: ->
      1
  
    getInfo: (arr) ->
      arr[0] = "ground"
      arr[1] = "I = " + Units.getCurrentText(@getCurrent())
  
    hasGroundConnection: (n1) ->
      true
  
    needsShortcut: ->
      true
  
    toString: ->
      "GroundElm"


  return GroundElm
