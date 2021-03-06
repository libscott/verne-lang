/* global exports */
"use strict";

// module Verne.Api

var Either = require('Data.Either');
var DataCode = require('Verne.Data.Code');

exports.make = function(ps) {
    var m = function(val) { return val.value0; }
    var e = function(val) {
        return val instanceof either.Left ? 
            {left: val.value0} : {right: val.value0};
    };
    var ex = function(val) {
        if (val instanceof either.Left) {
            throw val.value0;
        } else {
            return val.value0;
        }
    };
    var Code = function(program, str) {
        this.program = program;
        this.str = str;
        this.syntax = ex(ps.parse(str));
        this.code = program.run(ps.compile(this.syntax));
    }
    Code.prototype = {
        execute: function() {
            var exe = ex(ps.toExecutable(this.code));
            return ps.execute(exe);
        },
        getCompletion: function(caret) {
            var go = ps.getCompletions(caret)(this.code);
            return this.program.run(go);
        }
    }
    
    var Program = function() {
        this.state = ps.newProgramState;
    };
    Program.prototype = {
        run: function(act) {
            var tup = ps.runState(act)(this.state);
            this.state = tup.value1;
            return tup.value0;
        },
        addPart: function(object) {
            return ex(this.run(ps.importPart(object)));
        },
        compile: function(str) {
            return new Code(this, str);
        },
    };
    return Program;
};
