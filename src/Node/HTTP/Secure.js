"use strict";

var https = require("https");

exports.createServerImpl = function (options) {
  return function (handleRequest) {
    return function () {
      return https.createServer(options, function (req, res) {
        handleRequest(req)(res)();
      });
    };
  };
};
