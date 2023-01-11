import http2 from "http2";

export const createServer = options => () => {
  const server = http2.createServer(options);
  return server;
};

export const createSecureServer = options => () => {
  const server = http2.createSecureServer(options);
  return server;
};

// https://nodejs.org/docs/latest/api/net.html#serverlistenoptions-callback
export const listen = server => options => callback => () => {
  // TODO the completion callback should be Maybe Error -> Effect Unit
  server.listen(options, () => callback());
};

// https://nodejs.org/docs/latest/api/http2.html#serverclosecallback
export const closeServer = http2server => callback => () => {
  http2server.close(() => callback());
};

// https://nodejs.org/docs/latest/api/net.html#event-close
export const onceServerClose = server => callback => () => {
  const cb = () => callback();
  server.once("close", cb);
  return () => {server.removeEventListener("close", cb);};
};

export const onEmitterError = eventemitter => callback => () => {
  const cb = error => callback(error)();
  eventemitter.on("error", cb);
  return () => {eventemitter.removeListener("error", cb);};
};

export const session = http2stream => {
  return http2stream.session;
};

// https://nodejs.org/docs/latest/api/http2.html#event-stream
export const onStream = http2server => callback => () => {
  const cb = (stream, headers, flags) => callback(stream)(headers)(flags)();
  http2server.on("stream", cb);
  return () => {http2server.removeListener("stream", cb);};
};

// https://nodejs.org/docs/latest/api/http2.html#http2streampushallowed
export const pushAllowed = http2stream => () => {
  return http2stream.pushAllowed;
};

// https://nodejs.org/docs/latest/api/http2.html#http2streampushstreamheaders-options-callback
export const pushStream = http2stream => headers => options => callback => () => {
  http2stream.pushStream(headers, options,
    (err,pushStream2,headers2) => callback(err)(pushStream2)(headers2)()
  );
};

// https://nodejs.org/docs/latest/api/http2.html#http2streamadditionalheadersheaders
export const additionalHeaders = http2stream => headers => () => {
  http2stream.additionalHeaders(headers);
};
