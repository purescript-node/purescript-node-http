import http from "http";
import https from "https";

export function requestImpl(opts) {
  return function (k) {
    return function () {
      var lib = opts.protocol === "https:" ? https : http;
      return lib.request(opts, function (res) {
        k(res)();
      });
    };
  };
}

export function setTimeout(r) {
  return function (ms) {
    return function (k) {
      return function () {
        r.setTimeout(ms, k);
      };
    };
  };
}
