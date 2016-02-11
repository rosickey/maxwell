Util = require('../../util/util.coffee')
AndGateElm = require("./AndGateElm.coffee")

class NandGateElm extends AndGateElm
  constructor: (xa, ya, xb, yb, params, f)->
    super(xa, ya, xb, yb, params, f)

  isInverting: ()->
    true

  getGameName: ->
    "NAND Gate"

  getDumpType: ->
    151

module.exports = NandGateElm