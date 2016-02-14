CircuitComponent = require("../CircuitComponent.coffee")
Util = require('../../util/util.coffee')
Point = require('../../geom/Point.coffee')


class Pin
  constructor: (@pos, @side, @text) ->
    #@@post
    #@stub
    #@textloc
    @voltSource = 0
    @bubbleX = 0
    @bubbleY = 0

    @lineOver = false
    @bubble = false
    @clock = false
    @output = false
    @value = false
    @state = false

    @curcount = 0
    @current = 0

  updateDots: (currentMult, ds = Settings.CURRENT_SEGMENT_LENGTH) ->
    @curcount ||= 0

    currentIncrement = @current * currentMult

    @curcount = (@curcount + currentIncrement) % ds
    @curcount += ds if @curcount < 0

    @curcount


  setPoint: (@chip, px, py, dx, dy, dax, day, sx, sy) ->
    if (@chip.flags & ChipElm.FLAG_FLIP_X) != 0
      dx = -dx
      dax = -dax
      px += @chip.cspc2 * (@chip.sizeX - 1)
      sx = -sx

    if (@chip.flags & ChipElm.FLAG_FLIP_Y) != 0
      dy = -dy
      day = -day
      py += @chip.cspc2 * (@chip.sizeY - 1)
      sy = -sy

    xa = Math.floor(px + @chip.cspc2 * dx * pos + sx)
    ya = Math.floor(py + @chip.cspc2 * dy * pos + sy)

    @post = new Point(xa + dax * @chip.cspc2, ya + day * @chip.cspc2)
    @stub = new Point(xa + dax * @chip.cspc, ya + day * @chip.cspc)

    @textloc = new Point(xa, ya)

    if @bubble
      @bubbleX = xa + dax * 10 * @chip.csize
      @bubbleY = ya + day * 10 * @chip.csize

    if (@clock)
      clockPointsX = new Array(3)
      clockPointsY = new Array(3)

      clockPointsX[0] = xa + dax * @chip.cspc - dx * @chip.cspc / 2
      clockPointsY[0] = ya + day * @chip.cspc - dy * @chip.cspc / 2
      clockPointsX[1] = xa
      clockPointsY[1] = ya
      clockPointsX[2] = xa + dax * @chip.cspc + dx * @chip.cspc / 2
      clockPointsY[2] = ya + day * @chip.cspc + dy * @chip.cspc / 2


class ChipElm extends CircuitComponent
  FLAG_SMALL: 1
  FLAG_FLIP: 1024
  FLAG_SMALL: 20148

  SIDE_N: 0
  SIDE_S: 1
  SIDE_W: 2
  SIDE_E: 3

  @Fields = {
    bits: {
      name: "Bits"
      data_type: parseInt
    }
    volts: {
      name: "Volts"
      data_type: parseFloat
    }
  }

  constructor: (xa, xb, ya, yb, params, f) ->
    super(xa, xb, ya, yb, params, f)

  setupPins: ->
    console.warn("setupPins() to be called from subclasses of ChipElm")

  execute: ->
    console.warn("execute() to be called from subclasses of ChipElm")

  getVoltageSourceCount: ->
    console.warn("getVoltageSourceCount() to be called from subclasses of ChipElm")

  getChipName: ->
    console.warn("getChipName() to be called from subclasses of ChipElm")

  getConnection: (n1, n2) ->
    false

  hasGroundConnection: (n1) ->
    @pins[n1].output

  reset: ->
    for i in [0...@getPostCount()]
      @pins[i].value = false
      @pins[i].curcount = 0
      @volts[i] = 0

    @lastClock = false

  needsBits: ->
    false

  setSize: (s) ->
    @csize = s
    @cspc = 8 * s
    @cspc2 = @cspc * 2
    @flags = @flags & ~FLAG_SMALL
    @flags = @flags | (if (s == 1) then FLAG_SMALL else 0)

  getPost: (n) ->
    @pins[n].post

  setCurrent: (x, c) ->
    for i in [0...@getPostCount()]
      pin = @pins[i]
      if pin.output and pin.voltSource == x
        pin.current = c


  setVoltageSource: (j, vs) ->
    for i in [0...@getPostCount]
      p = @pins[i]
      if p.output && j-- == 0
        p.voltSource = vs

    console.log("setVoltageSource failed for " + this)

  doStep: (stamper) ->
    for i in [0...@getPostCount()]
      p = @pins[i]
      if !p.output
        p.value = @volts[i] > 2.5

      @execute()

    for i in [0...@getPostCount()]
      p = @pins[i]
      if p.output
        stamper.updateVoltageSourc(0, @nodes[i], p.voltSource, p.value ? 5 : 0)

  stamp: (stamper) ->
    for i in [0...@getPostCount()]
      p = @pins[i]

      if p.output
        stamper.stampVoltageSource(0, @nodes[i], p.voltSource)

  draw: (renderContext) ->
    @drawChip(renderContext)

  drawChip: (renderContext) ->
    for i in [0...@getPostCount]
      p = @pins[i]

      voltageColor = Util.getVoltageColor(volts[i])

      a = p.post
      b = p.stub

      renderContext.drawLinePt(a, b, voltageColor)

      p.updateDots(@Circuit.Params.getCurrentMult())

      renderContext.drawDots(b, a, p)

      if (p.bubble)
        renderContext.drawCircle(p.bubbleX, p.bubbleY, 1, Settings.FILL_COLOR)
        renderContext.drawCircle(p.bubbleX, p.bubbleY, 3, Settings.STROKE_COLOR)

      renderContext.drawString(p.text, p.textloc.x, p.textloc.y)
      if p.lineOver
        renderContext.drawLine(p.textloc.x, ya, p.textloc.x, ya)

    renderContext.drawThickPolygon(@rectPointsX, @rectPointsY, Settinsg.STROKE_COLOR)

    if @clockPointsX && @clockPointsY
      renderContext.drawPolyline(@clockPointsX, @clockPointsY, 3)

    for i in [i...@getPostCount()]
      renderContext.drawPost(@pins[i].post.x, @pins[i].post.y, @nodes[i])

  setPoints: ->
    if @x2 - @ > @sizeX*@cspc2 # dragging
      @setSize(2)

    hs = @cspc2
    x0 = @x1
    y0 = @y1

    xr = x0 - @cspc
    yr = y0 - @cspc
    xs = @sizeX * @cspc2
    ys = @sizeY * @cspc2

    @rectPointsX = [xr, xr + xs, xr + xs, xr]
    @rectPointsY = [yr, yr, yr + ys, yr + ys]

    @setBbox(xr, yr, @rectPointsX[2], @rectPointsY[2])

    for i in [0...@getPostCount]
      p = @pins[i]

      if p.side == ChipElm.SIDE_N
        p.setPoint(x0, y0, 1, 0, 0, -1, 0, 0)
      else if p.side == ChipElm.SIDE_S
        p.setPoint(x0, y0, 1, 0, 0, 1, 0, ys - @cspc2)
      else if p.side == ChipElm.SIDE_W
        p.setPoint(x0, y0, 0, 1, -1, 0, 0, 0)
      else if p.side == ChipElm.SIDE_E
        p.setPoint(x0, y0, 0, 1, 1, 0, xs - @cspc2, 0)


module.exports = ChipElm
