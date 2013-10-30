
(function() {
  var repl, script,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty;

  script = document.createElement("script");

  script.src = "http://coffeescript.org/extras/coffee-script.js";

  script.onload = function() {
    var e;
    try {
      return repl.start();
    } catch (_error) {
      e = _error;
      return alert("Internal error:\n" + e.message);
    }
  };

  document.body.appendChild(script);

  repl = {
    start: function() {
      var i, input, result, _results;
      this.callstack = 0;
      this.done = false;
      this.history = {
        lines: (function() {
          var _i, _results;
          _results = [];
          for (i = _i = 1; _i <= 5; i = ++_i) {
            _results.push("");
          }
          return _results;
        })(),
        add: function() {
          var lines;
          lines = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          this.lines.unshift(lines);
          return this.lines.pop();
        },
        toString: function() {
          return this.lines.join("\n");
        }
      };
      this.prompt = {
        read: "coffee> ",
        read_continued: "coffee. ",
        result: "=> "
      };
      _results = [];
      while (!this.done) {
        input = this.read();
        if (!this.preprocess(input)) {
          this.history.add(this.prompt.read + input);
          result = this["eval"](input);
          if (result.success) {
            window._ = result.value;
            this.print(this.prompt.result + this.inspect(result.value));
          } else {
            this.print(result.error);
          }
          _results.push(this.callstack = 0);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    },
    read: function() {
      return prompt(this.prompt.read + "\n" + this.history.toString());
    },
    "eval": function(code) {
      var error, result;
      result = {};
      try {
        result.value = eval(CoffeeScript.compile(code, {
          bare: true
        }));
        result.success = true;
      } catch (_error) {
        error = _error;
        result.error = error.message;
        result.success = false;
      }
      return result;
    },
    print: function(line) {
      return this.history.add(line);
    },
    inspect: function(obj) {
      var el, key, s, value;
      if (this.callstack++ > 10) {
        return obj;
      }
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
        default:
          alert("Internal error");
          return void 0;
      }
    },
    preprocess: function(input) {
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
    },
    exit: function() {
      return this.done = true;
    }
  };

}).call(this);
