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

export const onceSession = http2server => callback => () => {
  const cb = session => callback(session)();
  http2server.once("session", cb);
  return () => http2server.removeEventListener("session", cb);
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
