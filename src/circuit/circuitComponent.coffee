# #######################################################################
# CircuitComponent:
#   Base class from which all components inherit
#
# @author Anthony Erlinger
# @year 2012
#
# Uses the Observer Design Pattern:
#   Observes: Circuit, CircuitRender
#   Observed By: CircuitCanvas
#
# Events:
#  <None>
#
# #######################################################################

Settings = require('../settings/settings.coffee')
DrawHelper = require('../render/drawHelper.coffee')
Rectangle = require('../geom/rectangle.coffee')
Point = require('../geom/point.coffee')
MathUtils = require('../util/mathUtils.coffee')
ArrayUtils = require('../util/arrayUtils.coffee')


class CircuitComponent

  @ParameterDefinitions = {}

  constructor: (@x1 = 100, @y1 = 100, @x2 = 100, @y2 = 200, params = {}) ->
    @current = 0
    @curcount = 0
    @noDiagonal = false
    @selected = false
    @dragging = false
    @focused = false
    @Circuit = null

    @nodes = ArrayUtils.zeroArray(@getPostCount() + @getInternalNodeCount())
    @volts = ArrayUtils.zeroArray(@getPostCount() + @getInternalNodeCount())

    @setPoints()
    @initBoundingBox()
    @component_id = MathUtils.getRand(100000000) + (new Date()).getTime()

    @setParameters(params)

  convertParamsToHash: (param_list) ->
    convert = {
      "float": parseFloat,
      "integer": parseInt,
      "sign": Math.sign
    }

    result = {}

    ParameterDefinitions = @constructor.ParameterDefinitions

    for i in [0...param_list.length]
      param_name = Object.keys(ParameterDefinitions)[i]

      definition = ParameterDefinitions[param_name]
      data_type = definition.data_type

      param_value = param_list[i]
      result[param_name] = convert[data_type](param_value)

    console.log(@, "PARAMS: ", result)

    return result

  setParameters: (component_params) ->
    if component_params.constructor is Array
      component_params = @convertParamsToHash(component_params)

    convert = {
      "float": parseFloat,
      "integer": parseInt,
      "sign": Math.sign
    }

    ParameterDefinitions = @constructor.ParameterDefinitions

    for param_name, definition of ParameterDefinitions
      default_value = definition.default_value
      data_type = definition.data_type
      symbol = definition.symbol

      if param_name of component_params
        this[param_name] = convert[data_type](component_params[param_name])
        delete component_params[param_name]
      else
        this[param_name] = convert[data_type](default_value)
        console.warn("Defined parameter #{param_name} not set for #{this} (defaulting to #{default_value} #{symbol})")


    unmatched_params = (param for param of component_params)

    if unmatched_params.length > 0
      console.error("The following parameters #{unmatched_params.join(" ")} do not belong in #{this}")
      throw new Error("Invalid params #{unmatched_params.join(" ")} assigned to #{this}")


  serializeParameters: ->
    params = {}

    for param_name, definition of this.constructor.ParameterDefinitions
      params[param_name] = this[param_name]

    return params

  serialize: ->
    {
      sym: this.constructor.name,
      x1: @x1,
      y1: @y1,
      x2: @x2,
      y2: @y2,
      params: @serializeParameters()
    }

  @deserialize: (jsonData) ->
    sym = jsonData['sym']
    x1 = jsonData['x1']
    y1 = jsonData['y1']
    x2 = jsonData['x2']
    y2 = jsonData['y2']
    params = jsonData['params']

    params: @serializeParameters()

    Component = eval(sym)

    return new Component(x1, y2, x2, y2, params)


  getParentCircuit: ->
    return @Circuit

  setPoints: ->
    @dx = @x2 - @x1
    @dy = @y2 - @y1

    @dn = Math.sqrt(@dx * @dx + @dy * @dy)
    @dpx1 = @dy / @dn
    @dpy1 = -@dx / @dn

    @dsign = (if (@dy is 0) then MathUtils.sign(@dx) else MathUtils.sign(@dy))

    @point1 = new Point(@x1, @y1)
    @point2 = new Point(@x2, @y2)

  setPowerColor: (color) ->
    console.warn("Set power color not yet implemented")

  getDumpType: ->
    0

  reset: ->
    @volts = ArrayUtils.zeroArray(@volts.length)
    @curcount = 0

  setCurrent: (x, current) ->
    @current = current

  getCurrent: ->
    @current

  getVoltageDiff: ->
    @volts[0] - @volts[1]

  getPower: ->
    @getVoltageDiff() * @current

  calculateCurrent: ->
    # To be implemented by subclasses

    # Steps forward one frame and performs calculation
  doStep: ->
    # To be implemented by subclasses

  orphaned: ->
    return @Circuit is null or @Circuit is undefined

  destroy: =>
    @Circuit.desolder(this)

  startIteration: ->
    # Called on reactive elements such as inductors and capacitors.

  getPostVoltage: (post_idx) ->
    @volts[post_idx]

  setNodeVoltage: (node_idx, voltage) ->
    @volts[node_idx] = voltage
    @calculateCurrent()

  calcLeads: (len) ->
    if @dn < len or len is 0
      @lead1 = @point1
      @lead2 = @point2
#      console.log("Len: " + len)
      return

    #      console.log("Calc leads: #{@toString()}")
    @lead1 = DrawHelper.interpPoint(@point1, @point2, (@dn - len) / (2 * @dn))
    @lead2 = DrawHelper.interpPoint(@point1, @point2, (@dn + len) / (2 * @dn))


  # TODO: Validate consistency
  updateDotCount: (cur, cc) ->
    #      return cc  if CirSim.stoppedCheck
    cur = @current  if (isNaN(cur) || !cur?)
    cc = @curcount  if (isNaN(cc) || !cc?)

    cadd = cur * @Circuit.Params.getCurrentMult()
    #      cadd = cur * 48
    cadd %= 8
    @curcount = cc + cadd
    @curcount

  equalTo: (otherComponent) ->
    return @component_id == otherComponent.component_id

  drag: (newX, newY) ->
    newX = @Circuit.snapGrid(newX)
    newY = @Circuit.snapGrid(newY)
    if @noDiagonal
      if Math.abs(@x1 - newX) < Math.abs(@y1 - newY)
        newX = @x1
      else
        newY = @y1
    @x2 = newX
    @y2 = newY

    @setPoints()

  move: (deltaX, deltaY) ->
    @x1 += deltaX
    @y1 += deltaY
    @x2 += deltaX
    @y2 += deltaY

    @boundingBox.x = @x1
    @boundingBox.y = @x2

    @getParentCircuit().invalidate()

    @setPoints()

  stamp: ->
    throw("Called abstract function stamp() in Circuit #{@getDumpType()}")

  # Todo: implement needed
  getDumpClass: ->
    this.toString()

  # Returns the class name of this element (e.x. ResistorElm)
  toString: ->
    console.error("Virtual call on toString in circuitComponent was #{@constructor.name}")
#      return arguments.callee.name

  getVoltageSourceCount: ->
    0

  getInternalNodeCount: ->
    0

  setNode: (nodeIdx, newValue) ->
    @nodes[nodeIdx] = newValue

  setVoltageSource: (node, value) ->
    @voltSource = value

  getVoltageSource: ->
    @voltSource

  nonLinear: ->
    false

  # Two terminals by default, but likely to be overidden by subclasses
  getPostCount: ->
    2

  getNode: (nodeIdx) ->
    @nodes[nodeIdx]

  getPost: (postIdx) ->
    if postIdx == 0
      return @point1
    else if postIdx == 1
      return @point2

    console.printStackTrace()

  getBoundingBox: ->
    @boundingBox

  initBoundingBox: ->
    @boundingBox = new Rectangle()

    @boundingBox.x = Math.min(@x1, @x2)
    @boundingBox.y = Math.min(@y1, @y2)
    @boundingBox.width = Math.abs(@x2 - @x1) + 1
    @boundingBox.height = Math.abs(@y2 - @y1) + 1

  setBbox: (x1, y1, x2, y2) ->
    if x1 > x2
      temp = x1
      x1 = x2
      x2 = temp
    if y1 > y2
      temp = y1
      y1 = y2
      y2 = temp
    @boundingBox.x = x1
    @boundingBox.y = y1
    @boundingBox.width = x2 - x1 + 1
    @boundingBox.height = y2 - y1 + 1

  setBboxPt: (p1, p2, width) ->
    @setBbox p1.x, p1.y, p2.x, p2.y

    deltaX = (@dpx1 * width)
    deltaY = (@dpy1 * width)
    @adjustBbox p1.x + deltaX, p1.y + deltaY, p1.x - deltaX, p1.y - deltaY

  adjustBbox: (x1, y1, x2, y2) ->
    if x1 > x2
      q = x1
      x1 = x2
      x2 = q
    if y1 > y2
      q = y1
      y1 = y2
      y2 = q

    x1 = Math.min(@boundingBox.x, x1)
    y1 = Math.min(@boundingBox.y, y1)
    x2 = Math.max(@boundingBox.x + @boundingBox.width - 1, x2)
    y2 = Math.max(@boundingBox.y + @boundingBox.height - 1, y2)

    @boundingBox.x = x1
    @boundingBox.y = y1
    @boundingBox.width = x2 - x1
    @boundingBox.height = y2 - y1

  adjustBboxPt: (p1, p2) ->
    @adjustBbox p1.x, p1.y, p2.x, p2.y

  isCenteredText: ->
    false

  # Extended by subclasses
  getInfo: (arr) ->
    arr = new Array(15)

  # Extended by subclasses
  getBasicInfo: (arr) ->
    arr[1] = "I = " + DrawHelper.getCurrentDText(@getCurrent())
    arr[2] = "Vd = " + DrawHelper.getVoltageDText(@getVoltageDiff())
    3

  getScopeValue: (x) ->
    (if (x is 1) then @getPower() else @getVoltageDiff())

  getScopeUnits: (x) ->
    if (x is 1) then "W" else "V"

  getConnection: (n1, n2) ->
    true

  hasGroundConnection: (n1) ->
    false

  isWire: ->
    false

  canViewInScope: ->
    return @getPostCount() <= 2

  needsHighlight: ->
    @focused
  #      @Circuit?.mouseElm is this or @selected

  setSelected: (selected) ->
    @selected = selected

  isSelected: ->
    @selected

  needsShortcut: ->
    false

  ### #######################################################################
  # RENDERING METHODS
  ### #######################################################################

  draw: (renderContext) ->
    @curcount = @updateDotCount()
    @drawPosts(renderContext)
    @draw2Leads(renderContext)


  draw2Leads: (renderContext) ->
    if @point1? and @lead1?
      renderContext.drawThickLinePt @point1, @lead1, DrawHelper.getVoltageColor(@volts[0])
    if @point2? and @lead2?
      renderContext.drawThickLinePt @lead2, @point2, DrawHelper.getVoltageColor(@volts[1])


  drawDots: (point1 = @point1, point2 = @point2, renderContext) =>
    return if @Circuit?.isStopped() or @current is 0

    dx = point2.x - point1.x
    dy = point2.y - point1.y
#    dn = Math.sqrt(dx * dx + dy * dy)

    ds = 16

    currentIncrement = @current * @Circuit.currentSpeed()
    @curcount = (@curcount + currentIncrement) % ds
    @curcount += ds if @curcount < 0

    newPos = @curcount

    while newPos < @dn
      x0 = point1.x + newPos * dx / @dn
      y0 = point1.y + newPos * dy / @dn

      renderContext.fillCircle(x0, y0, Settings.CURRENT_RADIUS)
      newPos += ds

  ###
  Todo: Not yet implemented
  ###
  drawCenteredText: (text, x, y, doCenter, renderContext) ->
    strWidth = 10 * text.length
    x -= strWidth / 2 if doCenter
    ascent = -10
    descent = 5

    renderContext.fillStyle = Settings.TEXT_COLOR
    renderContext.fillText text, x, y + ascent

    @adjustBbox x, y - ascent, x + strWidth, y + ascent + descent

    return text


  ###
  # Draws relevant values near components
  #  e.g. 500 Ohms, 10V, etc...
  ###
  drawValues: (valueText, hs, renderContext) ->
    return unless valueText

    stringWidth = 100
    ya = -10

    xc = (@x2 + @x1) / 2
    yc = (@y2 + @y1) / 2
    dpx = Math.floor(@dpx1 * hs)
    dpy = Math.floor(@dpy1 * hs)
    offset = 20

    renderContext.fillStyle = Settings.TEXT_COLOR
    if dpx is 0
      renderContext.fillText valueText, xc - stringWidth / 2 + 3 * offset / 2, yc - Math.abs(dpy) - offset / 3
    else
      xx = xc + Math.abs(dpx) + offset
      #if this instanceof VoltageElm or (@x1 < @x2 and @y1 > @y2)
      #  xx = xc - (10 + Math.abs(dpx) + offset)
      renderContext.fillText valueText, xx, yc + dpy + ya


  drawPosts: (renderContext) ->
    for i in [0...@getPostCount()]
      post = @getPost(i)
      @drawPost post.x, post.y, @nodes[i], renderContext

  drawPost: (x0, y0, node, renderContext) ->
    #if node
    #return if not @Circuit?.dragElm? and not @needsHighlight() and @Circuit?.getNode(node).links.length is 2
    #return if @Circuit?.mouseMode is @Circuit?.MODE_DRAG_ROW or @Circuit?.mouseMode is @Circuit?.MODE_DRAG_COLUMN
    if @needsHighlight()
      fillColor = Settings.POST_COLOR_SELECTED
      strokeColor = Settings.POST_COLOR_SELECTED
    else
      fillColor = Settings.POST_COLOR
      strokeColor = Settings.POST_COLOR

    renderContext.fillCircle x0, y0, Settings.POST_RADIUS, 1, fillColor, strokeColor

  comparePair: (x1, x2, y1, y2) ->
    (x1 == y1 && x2 == y2) || (x1 == y2 && x2 == y1)

    @Circuit.Params

  timeStep: ->
    @Circuit.timeStep()


module.exports = CircuitComponent
