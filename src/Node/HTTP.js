"use strict";

var http = require('http');

exports.createServer = function(handleRequest) {
  return function() {
    return http.createServer(function(req, res) {
      handleRequest(req)(res)();
    });
  };
};

exports.listen = function(server) {
  return function(port) {
    return function(done) {
      return function() {
        server.listen(port, function() {
          done();
        });
      };
    };
  };
};

exports.setHeader = function(res) {
  return function(key) {
    return function(value) {
      return function() {
        res.setHeader(key, value);
      };
    };
  };
};

exports.setHeaders = function(res) {
  return function(key) {
    return function(values) {
      return function() {
        res.setHeader(key, values);
      };
    };
  };
};

exports.setStatusCode = function(res) {
  return function(code) {
    return function() {
      res.statusCode = code;
    };
  };
};

exports.setStatusMessage = function(res) {
  return function(message) {
    return function() {
      res.statusMessage = message;
    };
  };
};
