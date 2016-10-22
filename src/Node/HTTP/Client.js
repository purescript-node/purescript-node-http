"use strict";

var http = require("http");
var https = require("https");

exports.requestImpl = function (opts) {
  return function (k) {
    return function () {
      var lib = opts.protocol === "https:" ? https : http;
      return lib.request(opts, function (res) {
        k(res)();
      });
    };
  };
};

exports.setTimeout = function (r) {
  return function (ms) {
    return function (k) {
      return function () {
        r.setTimeout(ms, k);
      };
    };
  };
};
