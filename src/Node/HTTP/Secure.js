import https from "https";

export function createServerImpl(options) {
  return function (handleRequest) {
    return function () {
      return https.createServer(options, function (req, res) {
        handleRequest(req)(res)();
      });
    };
  };
}
