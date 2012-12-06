Circuit = require './../core/circuit'
Context = require './context'

class Renderer

  constructor: (@Circuit) ->
    @Context = new Context()

  drawComponents: ->
    for component in @Circuit.getElements()
      @drawComponent(component)

  drawComponent: (component) ->
    component.draw(@Context)

  draw2Leads: ->
    color = @setVoltageColor(@volts[0])
    @Context.drawThickLinePt @point1, @lead1, color
    color = @setVoltageColor(@volts[1])
    @Context.drawThickLinePt @lead2, @point2, color

  drawCircuit: ->
    renderContext.clearRect 0, 0, CANVAS.width(), CANVAS.height()

  drawInfo: ->
    # TODO: Find where to show data; below circuit, not too high unless we need it
    bottomTextOffset = 100
    ybase = @Circuit.getCircuitBottom - 15 * 1 - bottomTextOffset

  drawWarning: (context) ->
    msg = ""
    for warning in warningStack
      msg += warning + "\n"

    console.error "Simulation Warning: " + msg
    #context.fillText msg, 150, 70

  drawError: (context) ->
    msg = ""
    for error in errorStack
      msg += error + "\n"

    console.error "Simulation Error: " + msg
    #context.fillText msg, 150, 50

module.exports = Renderer