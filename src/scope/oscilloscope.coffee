# <DEFINE>
define ['Rickshaw', 'jQuery'], (Rickshaw, $) ->
# </DEFINE>

  class RenderControls

    constructor: (args) ->
      @element = args.element
      @graph = args.graph
      @settings = @serialize()

      @inputs =
        renderer: @element.elements.renderer
        interpolation: @element.elements.interpolation
        offset: @element.elements.offset

      @element.addEventListener "change", ((e) ->
        @settings = @serialize()
        @setDefaultOffset e.target.value  if e.target.name is "renderer"
        @syncOptions()
        @settings = @serialize()
        config =
          renderer: @settings.renderer
          interpolation: @settings.interpolation

        if @settings.offset is "value"
          config.unstack = true
          config.offset = "zero"
        else if @settings.offset is "expand"
          config.unstack = false
          config.offset = @settings.offset
        else
          config.unstack = false
          config.offset = @settings.offset
        @graph.configure config
        @graph.render()
        return
      ).bind(this), false


    @serialize = ->
      values = {}
      pairs = $(@element).serializeArray()
      pairs.forEach (pair) ->
        values[pair.name] = pair.value
        return

      values

    @syncOptions = ->
      options = @rendererOptions[@settings.renderer]
      Array::forEach.call @inputs.interpolation, (input) ->
        if options.interpolation
          input.disabled = false
          input.parentNode.classList.remove "disabled"
        else
          input.disabled = true
          input.parentNode.classList.add "disabled"
        return

      Array::forEach.call @inputs.offset, ((input) ->
        if options.offset.filter((o) ->
          o is input.value
        ).length
          input.disabled = false
          input.parentNode.classList.remove "disabled"
        else
          input.disabled = true
          input.parentNode.classList.add "disabled"
        return
      ).bind(this)
      return

    @setDefaultOffset = (renderer) ->
      options = @rendererOptions[renderer]
      if options.defaults and options.defaults.offset
        Array::forEach.call @inputs.offset, ((input) ->
          if input.value is options.defaults.offset
            input.checked = true
          else
            input.checked = false
          return
        ).bind(this)
      return

    @rendererOptions =
      area:
        interpolation: true
        offset: [
          "zero"
          "wiggle"
          "expand"
          "value"
        ]
        defaults:
          offset: "zero"

      line:
        interpolation: true
        offset: [
          "expand"
          "value"
        ]
        defaults:
          offset: "value"

      bar:
        interpolation: false
        offset: [
          "zero"
          "wiggle"
          "expand"
          "value"
        ]
        defaults:
          offset: "zero"

      scatterplot:
        interpolation: false
        offset: ["value"]
        defaults:
          offset: "value"

    initialize: ->
      return

  class Oscilloscope
    constructor: (@circuitElement, @timeInterval) ->
      @timeBase = Math.floor(new Date().getTime() / 1000);
      @timeInterval = 1
      @frames = 0

      @seriesData = []

      for i in [0..150]
        @addData @seriesData, 1


      graph = new Rickshaw.Graph(
        element: document.getElementById("chart")
        width: 400
        height: 200
        renderer: "line"
        stroke: true
        preserve: true
        series: [
          color: palette.color()
          data: @seriesData[0]
          name: "Data1"
        ]
      )
    graph.render()
    hoverDetail = new Rickshaw.Graph.HoverDetail(
      graph: graph
      xFormatter: (x) ->
        new Date(x * 1000).toString()
    )
    annotator = new Rickshaw.Graph.Annotate(
      graph: graph
      element: document.getElementById("timeline")
    )
    legend = new Rickshaw.Graph.Legend(
      graph: graph
      element: document.getElementById("legend")
    )
    shelving = new Rickshaw.Graph.Behavior.Series.Toggle(
      graph: graph
      legend: legend
    )
    order = new Rickshaw.Graph.Behavior.Series.Order(
      graph: graph
      legend: legend
    )
    highlighter = new Rickshaw.Graph.Behavior.Series.Highlight(
      graph: graph
      legend: legend
    )
    ticksTreatment = "glow"
    xAxis = new Rickshaw.Graph.Axis.Time(
      graph: graph
      ticksTreatment: ticksTreatment
      timeFixture: new Rickshaw.Fixtures.Time.Local()
    )
    xAxis.render()
    yAxis = new Rickshaw.Graph.Axis.Y(
      graph: graph
      tickFormat: Rickshaw.Fixtures.Number.formatKMBT
      ticksTreatment: ticksTreatment
    )
    yAxis.render()
    controls = new RenderControls(
      element: document.querySelector("form")
      graph: graph
    )

      palette = new Rickshaw.Color.Palette scheme: 'classic9'

    options: ->
      area:
        interpolation: true
        offset: [
          "zero"
          "wiggle"
          "expand"
          "value"
        ]
        defaults:
          offset: "zero"

      line:
        interpolation: true
        offset: [
          "expand"
          "value"
        ]
        defaults:
          offset: "value"

      bar:
        interpolation: false
        offset: [
          "zero"
          "wiggle"
          "expand"
          "value"
        ]
        defaults:
          offset: "zero"

      scatterplot:
        interpolation: false
        offset: ["value"]
        defaults:
          offset: "value"

    setup: () ->

    render: ->

    step: () ->
      @frames += 1
      @removeData(1);
      @addData(1);

    @addData = (value) ->
      amplitude = Math.cos(@timeBase / 50)
      index = @seriesData[0].length

      for item in @seriesData
        item.push x: index * @timeInterval + @timeBase, y: value + amplitude

    @removeData = (data) ->
      for item in @seriesData
        item.shift()

      @timeBase += @timeInterval



  return Oscilloscope
