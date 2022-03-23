import http from "http";

export function createServer(handleRequest) {
  return function () {
    return http.createServer(function (req, res) {
      handleRequest(req)(res)();
    });
  };
}

export function listenImpl(server) {
  return function (port) {
    return function (hostname) {
      return function (backlog) {
        return function (done) {
          return function () {
            if (backlog !== null) {
              server.listen(port, hostname, backlog, done);
            } else {
              server.listen(port, hostname, done);
            }
          };
        };
      };
    };
  };
}

export function closeImpl(server) {
  return function (done) {
    return function () {
      server.close(done);
    };
  };
}

export function listenSocket(server) {
  return function (path) {
    return function (done) {
      return function () {
        server.listen(path, done);
      };
    };
  };
}

export function onConnect(server) {
  return function (cb) {
    return function () {
      server.on("connect", function (req, socket, buffer) {
        return cb(req)(socket)(buffer)();
      });
    };
  };
}

export function onUpgrade(server) {
  return function (cb) {
    return function () {
      server.on("upgrade", function (req, socket, buffer) {
        return cb(req)(socket)(buffer)();
      });
    };
  };
}

export function setHeader(res) {
  return function (key) {
    return function (value) {
      return function () {
        res.setHeader(key, value);
      };
    };
  };
}

export function setHeaders(res) {
  return function (key) {
    return function (values) {
      return function () {
        res.setHeader(key, values);
      };
    };
  };
}

export function setStatusCode(res) {
  return function (code) {
    return function () {
      res.statusCode = code;
    };
  };
}

export function setStatusMessage(res) {
  return function (message) {
    return function () {
      res.statusMessage = message;
    };
  };
}
