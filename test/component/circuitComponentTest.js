// Generated by CoffeeScript 1.4.0
(function() {

  define(['cs!Polygon', 'cs!Rectangle', 'cs!Point', 'cs!CircuitComponent', 'cs!Circuit'], function(Polygon, Rectangle, Point, CircuitComponent, Circuit) {
    return describe("Base Circuit Component", function() {
      beforeEach(function() {
        this.Circuit = new Circuit();
        return this.circuitElement = new CircuitComponent(10, 10, 13, 14);
      });
      specify("class methods", function() {
        CircuitComponent.getScopeUnits(1).should.equal("W");
        return CircuitComponent.getScopeUnits().should.equal("V");
      });
      describe("arfter instantiating a new Circuit Component", function() {
        it("has correct initial position", function() {
          this.circuitElement.x1.should.equal(10);
          this.circuitElement.y1.should.equal(10);
          this.circuitElement.x2.should.equal(13);
          return this.circuitElement.y2.should.equal(14);
        });
        it("has correct dx and dy", function() {
          this.circuitElement.dx.should.eq(3);
          this.circuitElement.dy.should.eq(4);
          return this.circuitElement.dn.should.eq(5);
        });
        it("had default flag", function() {
          return this.circuitElement.flags.should.equal(0);
        });
        it("has flag passed as an argument", function() {
          var circuitElm;
          circuitElm = new CircuitComponent(0, 3, 0, 4, 5);
          return circuitElm.flags.should.equal(5);
        });
        it("creates default parameters", function() {
          this.circuitElement.current.should.equal(0);
          this.circuitElement.getCurrent().should.equal(0);
          this.circuitElement.noDiagonal.should.equal(false);
          return this.circuitElement.selected.should.equal(false);
        });
        it("default method return values", function() {
          this.circuitElement.getPostCount().should.equal(2);
          this.circuitElement.isSelected().should.equal(false);
          this.circuitElement.isWire().should.equal(false);
          this.circuitElement.hasGroundConnection().should.equal(false);
          this.circuitElement.needsHighlight().should.equal(false);
          this.circuitElement.needsShortcut().should.equal(false);
          return this.circuitElement.canViewInScope().should.equal(true);
        });
        it("should allocate nodes", function() {
          this.circuitElement.nodes.toString().should.equal([0, 0].toString());
          return this.circuitElement.volts.toString().should.equal([0, 0].toString());
        });
        it("should set points", function() {
          var x1, x2, y1, y2;
          x1 = this.circuitElement.x1;
          y1 = this.circuitElement.y1;
          x2 = this.circuitElement.x2;
          y2 = this.circuitElement.y2;
          this.circuitElement.setPoints();
          this.circuitElement.dx.should.equal(3);
          this.circuitElement.dy.should.equal(4);
          this.circuitElement.dn.should.equal(5);
          this.circuitElement.dpx1.should.equal(4 / 5);
          this.circuitElement.dpy1.should.equal(-(3 / 5));
          this.circuitElement.dsign.should.equal(1);
          this.circuitElement.point1.equals(new Point(x1, y1)).should.equal(true);
          return this.circuitElement.point2.equals(new Point(x2, y2)).should.equal(true);
        });
        it("should set bounding box", function() {
          var bBox;
          bBox = this.circuitElement.boundingBox;
          bBox.x.should.equal(10);
          bBox.y.should.equal(10);
          bBox.width.should.equal(4);
          return bBox.height.should.equal(5);
        });
        it("Has 0 current at its terminals", function() {
          return this.circuitElement.getCurrent().should.equal(0);
        });
        it("Has 0 power", function() {
          return this.circuitElement.getPower().should.equal(0);
        });
        it("Has the correct number of posts", function() {
          return this.circuitElement.getPostCount().should.equal(2);
        });
        it("Has no internal nodes", function() {
          return this.circuitElement.getInternalNodeCount().should.equal(0);
        });
        it("should have correct dump type", function() {
          return this.circuitElement.dump().should.equal('0 10 10 13 14 0');
        });
        specify("base elements should be linear by default", function() {
          return this.circuitElement.nonLinear().should.equal(false);
        });
        return describe("after soldering to circuit", function() {
          beforeEach(function() {
            return this.Circuit.solder(this.circuitElement);
          });
          it("is not be orphaned", function() {
            return this.circuitElement.orphaned().should.equal(false);
          });
          it("should be stampable", function() {});
          it("belongs to @Circuit", function() {
            return this.Circuit.getElmByIdx(0) === this.circuitElement;
          });
          it("belongs to @Circuit", function() {
            return this.Circuit.numElements() === 1;
          });
          describe("then destroying the component", function() {
            beforeEach(function() {
              return this.circuitElement.destroy();
            });
            it("is orphaned", function() {
              return this.circuitElement.orphaned().should.equal(true);
            });
            it("no longer belongs to @Circuit", function() {
              return this.Circuit.getElmByIdx(0) === null;
            });
            return it("belongs to @Circuit", function() {
              return this.Circuit.numElements().should.equal(0);
            });
          });
          return describe("then desoldering the component", function() {
            beforeEach(function() {
              return this.Circuit.desolder(this.circuitElement);
            });
            it("is orphaned", function() {
              return this.circuitElement.orphaned().should.equal(true);
            });
            it("no longer belongs to @Circuit", function() {
              return this.Circuit.getElmByIdx(0) === null;
            });
            return it("belongs to @Circuit", function() {
              return this.Circuit.numElements().should.equal(0);
            });
          });
        });
      });
      return describe("Should listen for", function() {
        return specify("onDraw(Context)", function() {});
      });
    });
  });

}).call(this);
