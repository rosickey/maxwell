{
  "type": "block",
  "src": "{",
  "value": "{",
  "lineno": 131,
  "children": [],
  "varDecls": [],
  "labels": {
    "table": {},
    "size": 0
  },
  "functions": [],
  "nonfunctions": [],
  "transformed": true
}
# Step 2: Prototype of SwitchElm is CircuitElement

# Step 3: Now we need to set the constructor to the DepthRectangle instead of Rectangle
SwitchElm = (xa, ya, xb, yb, f, st) ->
  CircuitElement.call this, xa, ya, xb, yb, f, st
  @momentary = false
  @position = 0
  @posCount = 2
  @ps = new Point(0, 0)
  CircuitElement.ps2 = new Point(0, 0)
  if st
    st = st.split(" ")  if typeof st is "string"
    str = st[0]
    if str is ("true")
      @position = (if (this instanceof LogicInputElm) then 0 else 1)
    else if str is ("false")
      @position = (if (this instanceof LogicInputElm) then 1 else 0)
    else
      @position = parseInt(str)
    @momentary = (st[1].toLowerCase() is "true")
  @posCount = 2
SwitchElm:: = new CircuitElement()
SwitchElm::constructor = SwitchElm
SwitchElm::getDumpType = ->
  "s"

SwitchElm::dump = ->
  CircuitElement::dump.call(this) + " " + @position + " " + @momentary

SwitchElm::setPoints = ->
  CircuitElement::setPoints.call this
  @calcLeads 32
  @ps = new Point(0, 0)
  CircuitElement.ps2 = new Point(0, 0)

SwitchElm::draw = ->
  openhs = 16
  hs1 = (if (@position is 1) then 0 else 2)
  hs2 = (if (@position is 1) then openhs else 2)
  @setBboxPt @point1, @point2, openhs
  @draw2Leads()
  @doDots()  if @position is 0
  
  #if (!needsHighlight())
  #	g.beginFill(Color.WHITE);
  CircuitElement.interpPoint @lead1, @lead2, @ps, 0, hs1
  CircuitElement.interpPoint @lead1, @lead2, CircuitElement.ps2, 1, hs2
  CircuitElement.drawThickLinePt @ps, CircuitElement.ps2, Settings.FG_COLOR
  @drawPosts()

SwitchElm::calculateCurrent = ->
  @current = 0  if @position is 1

SwitchElm::stamp = ->
  Circuit.stampVoltageSource @nodes[0], @nodes[1], @voltSource, 0  if @position is 0

SwitchElm::getVoltageSourceCount = ->
  (if (@position is 1) then 0 else 1)

SwitchElm.mouseUp = ->
  @toggle()  if @momentary

SwitchElm::toggle = ->
  @position++
  @position = 0  if @position >= @posCount

SwitchElm::getInfo = (arr) ->
  arr[0] = (if (@momentary) then "push switch (SPST)" else "switch (SPST)")
  if @position is 1
    arr[1] = "open"
    arr[2] = "Vd = " + CircuitElement.getVoltageDText(@getVoltageDiff())
  else
    arr[1] = "closed"
    arr[2] = "V = " + CircuitElement.getVoltageText(@volts[0])
    arr[3] = "I = " + CircuitElement.getCurrentDText(@getCurrent())

SwitchElm::getConnection = (n1, n2) ->
  @position is 0

SwitchElm::isWire = ->
  true

SwitchElm::getEditInfo = (n) ->


# TODO: Implement
#    if (n == 0) {
#        var ei:EditInfo = new EditInfo("", 0, -1, -1);
#        //ei.checkbox = new Checkbox("Momentary Switch", momentary);
#        return ei;
#    }
#    return null;
SwitchElm::setEditValue = (n, ei) ->
  n is 0


#momentary = ei.checkbox.getState();
CapacitorElm::toString = ->
  "SwitchElm"
