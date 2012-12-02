InductorElm = (xa, ya, xb, yb, f, st) ->
  AbstractCircuitComponent.call this, xa, ya, xb, yb, f
  @ind = new Inductor()
  if st
    st = st.split(" ")  if typeof st is "string"
    @inductance = parseFloat(st[0])
    @current = parseFloat(st[1])
  @ind.setup @inductance, @current, @flags
InductorElm:: = new AbstractCircuitComponent()
InductorElm::constructor = InductorElm
InductorElm::inductance = 0
InductorElm::draw = ->
  @doDots()
  v1 = @volts[0]
  v2 = @volts[1]
  i = undefined
  hs = 8
  @setBboxPt @point1, @point2, hs
  @draw2Leads()
  @setPowerColor false
  @drawCoil 8, @lead1, @lead2, v1, v2
  if Circuit.showValuesCheckItem
    s = AbstractCircuitComponent.getShortUnitText(@inductance, "H")
    @drawValues s, hs
  @drawPosts()

InductorElm::dump = ->
  AbstractCircuitComponent::dump.call(this) + " " + @inductance + " " + @current

InductorElm::getDumpType = ->
  "l"

InductorElm::startIteration = ->
  @ind.startIteration @volts[0] - @volts[1]

InductorElm::nonLinear = ->
  @ind.nonLinear()

InductorElm::calculateCurrent = ->
  voltdiff = @volts[0] - @volts[1]
  @current = @ind.calculateCurrent(voltdiff)

InductorElm::doStep = ->
  voltdiff = @volts[0] - @volts[1]
  @ind.doStep voltdiff

InductorElm::getInfo = (arr) ->
  arr[0] = "inductor"
  @getBasicInfo arr
  arr[3] = "L = " + AbstractCircuitComponent.getUnitText(@inductance, "H")
  arr[4] = "P = " + AbstractCircuitComponent.getUnitText(@getPower(), "W")

InductorElm::reset = ->
  @current = @volts[0] = @volts[1] = @curcount = 0
  @ind.reset()

InductorElm::getEditInfo = (n) ->
  return new EditInfo("Inductance (H)", @inductance, 0, 0)  if n is 0
  if n is 1
    ei = new EditInfo("", 0, -1, -1)
    ei.checkbox = "Trapezoidal Approximation" # new Checkbox("Trapezoidal Approximation",	ind.isTrapezoidal());
    return ei
  null

InductorElm::setEditValue = (n, ei) ->
  
  # TODO Auto Generated method stub
  @inductance = ei.value  if n is 0
  if n is 1
    if ei.checkbox.getState()
      @flags &= ~Inductor.FLAG_BACK_EULER
    else
      @flags |= Inductor.FLAG_BACK_EULER
  @ind.setup @inductance, @current, @flags

InductorElm::setPoints = ->
  AbstractCircuitComponent::setPoints.call this
  @calcLeads 32

InductorElm::stamp = ->
  @ind.stamp @nodes[0], @nodes[1]