CircuitComponent = require("../CircuitComponent.coffee")
Util = require('../../util/util.coffee')

class GateElm extends CircuitComponent
  FLAG_SMALL: 1

  @ParameterDefinitions = {
    inputCount: {
      name: "Input count"
      data_type: parseInt
      default_value: 2
    },
    lastOutput: {
      name: "Last Output"
      data_type: parseInt
      default_value: 0
    }
  }

  constructor: (xa, ya, xb, yb, params, f) ->
    super(xa, ya, xb, yb, params, f)

    @noDiagonal = true

    @setSize(2)

  isInverting: ->
    false

  setSize: (s) ->
    @gsize = s
    @gwidth = 7 * s
    @gwidth2 = 14 * s
    @gheight = 8 * s
    if s == 1
      @flags = GateElm.FLAG_SMALL
    else
      @flags = 0

  setPoints: ->
    super()

    if @dn > 150
      @setSize(2)

    hs = @gheight
    @ww = @gwidth2

    if @ww > @dn/2
      @ww = Math.floor(@dn/2)

    if @isInverting() && (@ww + 8 > @dn/2)
      @ww = Math.floor(@dn / 2 - 8)

    @calcLeads @ww*2

    @inPosts = Util.newPointArray(@inputCount)
    @inGates = Util.newPointArray(@inputCount)

    @allocNodes()

    i0 = -@inputCount / 2

#    while i < @inputCount
    for i in [0...@inputCount]
      if i0==0 && @inputCount & 1 == 0
        i0 += 1

      @inPosts[i] = Util.interpolate(@point1, @point2, 0, hs * 10)
      @inGates[i] = Util.interpolate(@lead1, @lead2, 0, hs * 10)

      if (@lastOutput ^ @isInverting())
        @volts[i] = 5
      else
        @volts[i] = 0

      i0 += 1

    @hs2 = @gwidth * (@inputCount / 2 + 1)
    @setBboxPt(@point1, @point2, @hs2)


  doStep: (stamper) ->
    @calcFunction()

    if @isInverting()
      @f = !@f

    @lastOutput = @f

    if @f
      res = 5
    else
      res = 0

    stamper.updateVoltageSource(0, @nodes[@inputCount], @voltageSource, res)

  getPostCount: ->
    @inputCount + 1

  getVoltageSourceCount: ->
    1

  getPost: (n) ->
    if n == @inputCount
      return @point2

    @inPosts[n]

  getInput: (n)->
    return @volts[n] > 2.5

  getConnection: (n1, n2)->
    return false

  hasGroundConnection: (n1) ->
    n1 == @inputCount

  getGetName: ->

  stamp: (stamper) ->
    stamper.stampVoltageSource(0, @nodes[@inputCount], @voltSource)



module.exports = GateElm