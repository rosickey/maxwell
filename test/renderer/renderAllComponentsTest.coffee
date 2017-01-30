describe "Render all components", ->
  it "can render all components", ->
    this.timeout(5000)

    nComponents = Object.keys(Components).length

    col = 0
    height = 80

    offsetX = 140
    nCols = 8

    Canvas = require('canvas')
    @canvas = new Canvas((nCols + 1) * offsetX, 2 * height * (Math.ceil(nComponents / nCols)))

    ctx = @canvas.getContext('2d')

    @Circuit = new Circuit("AllComponents")

    @renderer = new CircuitUI(@Circuit, @canvas)
    ctx.imageSmoothingEnabled = true
    @renderer.context = ctx

    for component_name of Components
      console.log(component_name)
      Component = Components[component_name]

      if (component_name not in ['ChipElm', 'GateElm', '170', 'A', 'o', '$', '%', '?', 'B'] && component_name[0] != "_")
        x = col % (nCols * offsetX) + offsetX/2
        y = 2 * Math.floor(col / (offsetX * nCols)) * height + height

        @component = new Component(x, y, x, y + height)
        @Circuit.solder(@component)
        @component.setPoints()

        origfont = ctx.font
        ctx.font = "bold 12px Arial";

        mt = ctx.measureText(@component.getName());
        ctx.fillText(@component.getName(), x - mt.width/2, y - 30)
        ctx.font = origfont

        col += offsetX

        # Render individual circuit component

        @singleComponent = new Component(50, 50, 50, 125);
        @ComponentCircuit = new Circuit(@singleComponent.getName());
        @ComponentCircuit.solder(@singleComponent);

        @singleComponent.setPoints()

        @ComponentCanvas = new Canvas(200, 300);
        componentUI = new CircuitUI(@ComponentCircuit, @ComponentCanvas);
        componentUI.CircuitCanvas.drawComponents();

        fs.writeFileSync("test/fixtures/componentRenders/" + @component.getName() + ".png", @ComponentCanvas.toBuffer())

    @renderer.CircuitCanvas.drawComponents()

    fs.writeFileSync("test/fixtures/componentRenders/all_components.png", @canvas.toBuffer())
    fs.writeFileSync("test/fixtures/circuitDumps/allComponents.json", JSON.stringify(@Circuit.serialize()))

    #console.log(@Circuit.serialize())

