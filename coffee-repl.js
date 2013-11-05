// Generated by CoffeeScript 1.6.3
(function() {
  var autocomplete, dir, getPropertys, include, space, suggest, type, _eval;

  window.REPL = (function() {
    var repl;

    repl = null;

    function REPL() {
      var _this = this;
      if (repl != null) {
        return repl;
      }
      repl = this;
      this.run = false;
      this.env = {
        log: function(str) {
          _this.printbuffer += str + "\n";
          return void 0;
        },
        clear: function() {
          _this.printbuffer = "";
          _this.printlogs = ["", "", "", "", ""];
          return void 0;
        },
        dir: dir,
        type: type,
        grep: null,
        include: include,
        $_: void 0
      };
      this.history = [];
      this.printbuffer = "";
      this.printlogs = ["", "", "", "", ""];
      this.defaultInput = "";
    }

    REPL.prototype.help = ".exit / Exit the REPL\n.help / Show repl options\n.1 / last input\n.n / nth input\n.jquery / include(\"jQuery.js\")\n.underscore / include(\"underscore.js\")\n.prototype / include(\"prototype.js\")\n\nword[space][OK] / autocomplete \n\nlog(str)\nclear()\ndir(obj [, maxCallNum])\ntype(obj)\ninclude(url)\n$_";

    REPL.prototype.start = function() {
      this.run = true;
      return this.loop();
    };

    REPL.prototype.loop = function() {
      var ary, err, input, n, pre, _ref,
        _this = this;
      input = prompt(this.printlogs.join("\n"), this.defaultInput) || ".exit";
      this.history.unshift(input);
      console.log(input);
      this.defaultInput = "";
      if (/\.exit$/.test(input)) {
        this.run = false;
        this.printlogs.unshift("coffee> " + input + "\n\n");
      } else if (/\.help$/.test(input)) {
        this.printlogs.unshift("coffee> " + input + "\n" + this.help + "\n");
      } else if (/\.jQuery$/.test(input)) {
        this.printlogs.unshift("coffee> " + input + "\n\n");
        this.run = false;
        include("//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js", function() {
          return _this.start();
        });
      } else if (/\.underscore$/.test(input)) {
        this.printlogs.unshift("coffee> " + input + "\n\n");
        this.run = false;
        include("http://underscorejs.org/underscore-min.js", function() {
          return _this.start();
        });
      } else if (/\.prototype$/.test(input)) {
        this.printlogs.unshift("coffee> " + input + "\n\n");
        this.run = false;
        include("//ajax.googleapis.com/ajax/libs/prototype/1.7.1.0/prototype.js", function() {
          return _this.start();
        });
      } else if (n = (/\.(\d+)$/.exec(input) || [false, false])[1]) {
        this.defaultInput = this.history[n];
      } else if (/\s$/.test(input)) {
        _ref = autocomplete(input, this.env), pre = _ref[0], ary = _ref[1];
        if (ary.length === 1) {
          this.defaultInput = (pre + " " + ary[0]).replace(/^\s+/, "");
        } else {
          this.defaultInput = input.replace(/\s+$/, "");
          this.printlogs.unshift("coffee> " + input + "\n" + (ary.join("\n")) + "\n");
        }
      } else {
        try {
          this.env.$_ = _eval(input, this.env);
        } catch (_error) {
          err = _error;
          this.env.$_ = "" + err;
        }
        this.printlogs.unshift("coffee> " + input + "\n" + this.printbuffer + (dir(this.env.$_)));
        this.printbuffer = "";
      }
      console.log(this.printlogs[0]);
      this.printlogs.length = 5;
      if (this.run) {
        setTimeout(function() {
          return _this.loop();
        });
      }
      return void 0;
    };

    return REPL;

  })();

  include = function(url, next) {
    var script;
    script = document.createElement("script");
    script.src = url;
    script.onload = next;
    document.body.appendChild(script);
    return void 0;
  };

  _eval = function(code, env) {
    var args, oprs,
      _this = this;
    if (env == null) {
      env = {};
    }
    args = Object.keys(env);
    oprs = args.map(function(key) {
      return env[key];
    });
    return Function.apply(null, args.concat(CoffeeScript.compile("return do->\n  " + code.split("\n").join("\n  "), {
      bare: true
    }))).apply(window, oprs);
  };

  /*
  console.assert(_eval("do->window") is window, "_eval")
  */


  getPropertys = function(o) {
    var ary, key, tmp, _ary;
    if (o == null) {
      return [];
    }
    ary = [].concat(Object.getOwnPropertyNames(o), (function() {
      var _results;
      _results = [];
      for (key in o) {
        _results.push(key);
      }
      return _results;
    })());
    tmp = {};
    _ary = ary.filter(function(key) {
      if (tmp[key] != null) {
        return false;
      } else {
        return tmp[key] = true;
      }
    });
    return _ary.sort();
  };

  /*
  console.assert(""+getPropertys({a:0}) is ""+getPropertys(Object.create({a:0})), "getPropertys")
  */


  suggest = function(code, token, env) {
    var err, reg, result;
    if (env == null) {
      env = {};
    }
    reg = new RegExp("^" + token + ".*");
    try {
      result = _eval(code, env);
    } catch (_error) {
      err = _error;
      result = {};
    }
    return getPropertys(result).filter(function(key) {
      return reg.test(key);
    });
  };

  /*
  console.assert(suggest("window", "conso")[0] is "console", "suggest conso")
  console.assert(suggest("console", "lo")[0]   is "log",     "suggest console.lo")
  console.assert(suggest("Math", "p")[0]       is "pow",     "suggest Math.p")
  */


  autocomplete = function(code, env) {
    var ary, key, obj, pre, result, token, tokens;
    if (env == null) {
      env = {};
    }
    tokens = (code + " ").split(/\s+/).slice(0, -1);
    token = tokens.pop();
    pre = tokens.join(" ");
    if (token.indexOf(".") === -1) {
      result = suggest("window", token, env).map(function(str) {
        return str.replace(/\s+$/, "");
      });
    } else {
      ary = token.split(".");
      obj = ary.slice(0, -1).join(".");
      key = ary[ary.length - 1];
      result = suggest(obj, key, env).map(function(str) {
        return obj + "." + str.replace(/\s+$/, "");
      });
    }
    return [pre, result];
  };

  /*
  console.assert(autocomplete("conso")[0]         is "" and
                 autocomplete("conso")[1][0]      is "console",      "autocomplete conso")
  console.assert(autocomplete("console.lo")[0]    is "" and
                 autocomplete("console.lo")[1][0] is "console.log",  "autocomplete console.lo")
  console.assert(autocomplete("if {a:0}.")[0]     is "if"
                 autocomplete("if {a:0}.")[1][0]  is "{a:0}.a",      "autocomplete {a:0}.")
  */


  type = function(o) {
    var _type;
    if (o === null) {
      return "null";
    } else if (o === void 0) {
      return "undefined";
    } else if (o === window) {
      return "global";
    } else if (o.nodeType) {
      return "node";
    } else if (typeof o !== "object") {
      return typeof o;
    } else {
      _type = Object.prototype.toString.call(o);
      if (_type === "[object Object]") {
        _type = "" + o.constructor;
      }
      return (/^\[object (\w+)\]$/.exec(_type) || /^\s*function\s+(\w+)/.exec(_type) || ["", "object"])[1].toLowerCase();
    }
  };

  /*
  console.assert(type(null)      is "null",      "type null")
  console.assert(type(undefined) is "undefined", "type undefined")
  console.assert(type(true)      is "boolean",   "type boolean")
  console.assert(type(0)         is "number",    "type number")
  console.assert(type("string")  is "string",    "type string")
  console.assert(type(->)        is "function",  "type function")
  console.assert(type([])        is "array",     "type array")
  console.assert(type({})        is "object",    "type object")
  console.assert(type(new Date)  is "date",      "type date")
  console.assert(type(Math)      is "math",      "type math")
  console.assert(type(/0/)       is "regexp",    "type regexp")
  console.assert(type(window)    is "global",    "type global")
  console.assert(type(document.body) is "node",  "type node")
  console.assert(type(new (class Foo)) is "foo", "type foo")
  */


  space = function(i) {
    var _i, _results;
    return (function() {
      _results = [];
      for (var _i = 0; 0 <= i ? _i <= i : _i >= i; 0 <= i ? _i++ : _i--){ _results.push(_i); }
      return _results;
    }).apply(this).map(function() {
      return "";
    }).join("  ");
  };

  /*
  console.assert(space(0) is "",   "space 0")
  console.assert(space(1) is "  ", "space 1")
  */


  dir = function(o, max, i) {
    var dumpObj, v;
    if (max == null) {
      max = 1;
    }
    if (i == null) {
      i = 0;
    }
    dumpObj = function(o) {
      if (getPropertys(o).length === 0) {
        return "{}";
      } else {
        return "{\n" + ((getPropertys(o).map(function(k) {
          return "" + (space(i + 1)) + k + ": " + (dir(o[k], max, i + 1));
        })).join(",\n")) + "\n" + (space(i)) + "}";
      }
    };
    switch (type(o)) {
      case "null":
      case "undefined":
      case "boolean":
      case "number":
        return "" + o;
      case "string":
        return "\"" + o + "\"";
      case "function":
        return Object.prototype.toString.call(o);
      case "date":
        return JSON.stringify(o);
      case "array":
        if (i < max) {
          return "[" + (((function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = o.length; _i < _len; _i++) {
              v = o[_i];
              _results.push(dir(v, max, i + 1));
            }
            return _results;
          })()).join(", ")) + "]";
        } else {
          return Object.prototype.toString.call(o);
        }
        break;
      default:
        if (i < max) {
          return dumpObj(o);
        } else {
          return Object.prototype.toString.call(o);
        }
    }
  };

  /*
  console.assert(dir({a:0}) is dir(Object.create({a:0})), "dir")
  */


  if (window.CoffeeScript != null) {
    setTimeout(function() {
      return (new REPL).start();
    });
  } else {
    include("https://dl.dropboxusercontent.com/u/265158/coffee-script.js", function() {
      return (new REPL).start();
    });
  }

}).call(this);

/*
//@ sourceMappingURL=coffee-repl.map
*/
