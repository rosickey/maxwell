# <DEFINE>
define [
  'cs!Diode',
  'cs!Settings',
  'cs!DrawHelper',
  'cs!Polygon',
  'cs!Rectangle',
  'cs!Point',
  'cs!CircuitComponent',
  'cs!Units'

], (
  Diode,
  Settings,
  DrawHelper,
  Polygon,
  Rectangle,
  Point,

  CircuitComponent,
  Units
) ->
  # </DEFINE>

  class DiodeElm extends CircuitComponent

    @FLAG_FWDROP: 1
    @DEFAULT_DROP: .805904783

    constructor: (xa, ya, xb, yb, f, st) ->
      super xa, ya, xb, yb, f

      @hs = 8
      @poly
      @cathode = []

      @diode = new Diode(self)
      @fwdrop = DiodeElm.DEFAULT_DROP
      @zvoltage = 0

      if (f & DiodeElm.FLAG_FWDROP) > 0
        try
          @fwdrop = parseFloat(st)

      @setup()

    nonLinear: ->
      true

    setup: ->
      @diode.setup @fwdrop, @zvoltage

    getDumpType: ->
      "d"

    dump: ->
      @flags |= DiodeElm.FLAG_FWDROP
      CircuitComponent::dump.call(this) + " " + @fwdrop

    setPoints: ->
      super()
      @calcLeads 16
      @cathode = CircuitComponent.newPointArray(2)
      [pa, pb] = DrawHelper.interpPoint2 @lead1, @lead2, 0, @hs
      [ca, cb] = DrawHelper.interpPoint2 @lead1, @lead2, 1, @hs
      @poly = DrawHelper.createPolygonFromArray([pa, pb, @lead2])

    draw: (renderContext) ->
      @drawDiode(renderContext)
      @drawDots(renderContext)
      @drawPosts(renderContext)

    reset: ->
      @diode.reset()
      @volts[0] = @volts[1] = @curcount = 0

    drawDiode: (renderContext) ->
      @setBboxPt @point1, @point2, @hs
      v1 = @volts[0]
      v2 = @volts[1]
      @draw2Leads(renderContext)

      # TODO: RENDER DIODE

      # draw arrow
      #this.setPowerColor(true);
#      color = @setVoltageColor(v1)
#      renderContext.drawThickPolygonP @poly, color

      #g.fillPolygon(poly);

      # draw thing diode plate
#      color = @setVoltageColor(v2)
#      renderContext.drawThickLinePt @cathode[0], @cathode[1], color

    stamp: (stamper) ->
      @diode.stamp @nodes[0], @nodes[1], stamper

    doStep: (Stamper) ->
      @diode.doStep @volts[0] - @volts[1], Stamper

    calculateCurrent: ->
      @current = @diode.calculateCurrent(@volts[0] - @volts[1])

    getInfo: (arr) ->
      arr[0] = "diode"
      arr[1] = "I = " + DrawHelper.getCurrentText(@getCurrent())
      arr[2] = "Vd = " + DrawHelper.getVoltageText(@getVoltageDiff())
      arr[3] = "P = " + DrawHelper.getUnitText(@getPower(), "W")
      arr[4] = "Vf = " + DrawHelper.getVoltageText(@fwdrop)

    getEditInfo: (n) ->
      return new EditInfo("Fwd Voltage @ 1A", @fwdrop, 10, 1000)  if n is 0

    setEditValue: (n, ei) ->
      @fwdrop = ei.value
      @setup()


    # TODO: fix
    needsShortcut: ->
      return true

  return DiodeElm
