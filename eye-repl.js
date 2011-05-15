javascript:

(function() {
  var EyeREPL, History, repl;
  var __hasProp = Object.prototype.hasOwnProperty, __slice = Array.prototype.slice;
  EyeREPL = (function() {
    function EyeREPL() {
      this.done = false;
      this.history = new History;
      this.prompt = {
        read: "js> ",
        read_continued: "js. ",
        result: "=> "
      };
    }
    EyeREPL.prototype.start = function() {
      var input, result, _results;
      _results = [];
      while (!this.done) {
        input = this.read();
        _results.push(!this.preprocess(input) ? (this.history.add(this.prompt.read + input), result = this.eval(input), result.success ? (window._ = result.value, this.print(this.prompt.result + this.inspect(result.value))) : this.print(result.error)) : void 0);
      }
      return _results;
    };
    EyeREPL.prototype.read = function() {
      return prompt(this.prompt.read + "\n" + this.history.toString());
    };
    EyeREPL.prototype.eval = function(code) {
      var result;
      result = {};
      try {
        result.value = eval(code);
        result.success = true;
      } catch (error) {
        result.error = error.message;
        result.success = false;
      }
      return result;
    };
    EyeREPL.prototype.print = function(line) {
      return this.history.add(line);
    };
    EyeREPL.prototype.inspect = function(obj) {
      var el, key, s, value;
      switch (typeof obj) {
        case "number":
        case "boolean":
        case "function":
          return "" + obj;
        case "undefined":
          return "undefined";
        case "object":
          if (obj === null) {
            return "null";
          } else if (Object.prototype.toString.apply(obj) === "[object Array]") {
            return "[" + ((function() {
              var _i, _len, _results;
              _results = [];
              for (_i = 0, _len = obj.length; _i < _len; _i++) {
                el = obj[_i];
                _results.push(this.inspect(el));
              }
              return _results;
            }).call(this)).join(", ") + "]";
          } else {
            s = ((function() {
              var _results;
              _results = [];
              for (key in obj) {
                if (!__hasProp.call(obj, key)) continue;
                value = obj[key];
                _results.push("" + (this.inspect(key)) + ": " + (this.inspect(value)));
              }
              return _results;
            }).call(this)).join(", ");
            if (s === "") {
              return "{}";
            } else {
              return "{ " + s + " }";
            }
          }
          break;
        case "string":
          return "\"" + obj + "\"";
          break;
        default:
          alert("Internal error");
          return;
      }
    };
    EyeREPL.prototype.preprocess = function(input) {
      var matches;
      if (input === null) {
        input = ":exit";
      }
      if (matches = input.match(/^:(\w+)$/)) {
        this[matches[1]]();
        return true;
      } else {
        return false;
      }
    };
    EyeREPL.prototype.exit = function() {
      return this.done = true;
    };
    return EyeREPL;
  })();
  History = (function() {
    function History() {
      var i;
      this.lines = [];
      for (i = 1; i <= 5; i++) {
        this.add("");
      }
    }
    History.prototype.add = function() {
      var lines, _ref;
      lines = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref = this.lines).unshift.apply(_ref, lines);
    };
    History.prototype.toString = function() {
      return this.lines.join("\n");
    };
    return History;
  })();
  try {
    repl = new EyeREPL;
    repl.start();
  } catch (error) {
    alert("Internal error:\n" + error.message);
  }
}).call(this);
