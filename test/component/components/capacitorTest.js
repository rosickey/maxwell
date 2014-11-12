// Generated by CoffeeScript 1.8.0
(function() {
  define(['cs!CapacitorElm', 'cs!Circuit'], function(CapacitorElm, Circuit) {
    return describe("Capacitor Component", function() {
      beforeEach(function() {
        this.Circuit = new Circuit();
        return this.capacitor = new CapacitorElm(100, 100, 100, 200, 0.1, [1e-9, 1.1]);
      });
      it("should have correct defaults", function() {
        this.capacitor.capacitance.should.equal(1e-9);
        return this.capacitor.voltdiff.should.equal(1.1);
      });
      it("should have correct number of posts", function() {
        this.capacitor.getPostCount().should.equal(2);
        return this.capacitor.getInternalNodeCount().should.equal(0);
      });
      it("should not have any internal voltage sources", function() {
        return this.capacitor.getVoltageSourceCount().should.equal(0);
      });
      it("should have correct dump type", function() {
        return this.capacitor.getDumpType().should.equal("c");
      });
      it("should have correct toString()", function() {
        return this.capacitor.toString().should.equal("Capacitor");
      });
      it("should be orphaned", function() {
        return this.capacitor.orphaned().should.equal(true);
      });
      return describe("after soldering to circuit", function() {
        beforeEach(function() {
          return this.Circuit.solder(this.capacitor);
        });
        it("should get voltage correctly", function() {
          return this.capacitor.getVoltageDiff().should.equal(0);
        });
        it("should not be orphaned", function() {
          return this.capacitor.orphaned().should.equal(false);
        });
        it("should be stampable", function() {
          return this.capacitor.stamp(this.Circuit.Solver.Stamper);
        });
        it("should be steppable", function() {
          return this.capacitor.doStep();
        });
        it("should be drawable", function() {});
        return it("should setPoints", function() {
          return this.capacitor.setPoints();
        });
      });
    });
  });

}).call(this);

//# sourceMappingURL=capacitorTest.js.map
