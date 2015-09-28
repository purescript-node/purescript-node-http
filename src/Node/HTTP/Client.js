"use strict";

// module Node.HTTP.Client

var http = require('http');

exports.requestImpl = function(opts) {
  return function(k) {
    return function() {
      return http.request(opts, function(res) {
        k(res)();
      });
    };
  };
};
