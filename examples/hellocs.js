// Generated by CoffeeScript 1.4.0
(function() {

  define(['jquery'], function($) {
    var Hello;
    Hello = (function() {

      function Hello(hello) {
        this.hello = hello;
      }

      Hello.prototype.sayHi = function() {
        return console.log(this.hello);
      };

      return Hello;

    })();
    return Hello;
  });

}).call(this);