import http2 from "http2";

// https://nodejs.org/docs/latest/api/http2.html#http2connectauthority-options-listener
// https://nodejs.org/docs/latest/api/http2.html#event-connect
export const connect = authority => options => listener => () => {
  return http2.connect(authority, options,
    (session,socket) => listener(session)(socket)()
  );
};

// https://stackoverflow.com/questions/67790720/node-js-net-connect-error-in-spite-of-try-catch
export const connectWithError = authority => options => listener => cberror => () => {
  return http2.connect(authority, options,
    (session,socket) => listener(session)(socket)()
  ).once("error", err => cberror(err)());
};

export const onceReady = socket => callback => () => {
  socket.once("ready", callback);
  return () => socket.removeEventListener("ready", callback);
};

// https://nodejs.org/docs/latest/api/http2.html#event-stream
export const onceStream = foreign => callback => () => {
  const cb = (stream, headers, flags) => callback(stream)(headers)(flags)();
  foreign.once("stream", cb);
  return () => {foreign.removeListener("stream", cb);};
};

// https://nodejs.org/docs/latest/api/http2.html#clienthttp2sessionrequestheaders-options
export const request = clienthttp2session => headers => options => () => {
  return clienthttp2session.request(headers, options);
};

export const destroy = clienthttp2stream => () => {
  clienthttp2stream.destroy();
};

// https://nodejs.org/docs/latest/api/http2.html#event-response
export const onceResponse = clienthttp2stream => callback => () => {
  const cb = (headers,flags) => callback(headers)(flags)();
  clienthttp2stream.once("response", cb);
  return () => clienthttp2stream.removeEventListener("response", cb);
};

// https://nodejs.org/docs/latest/api/http2.html#event-headers
export const onceHeaders = clienthttp2stream => callback => () => {
  const cb = (headers,flags) => callback(headers)(flags)();
  clienthttp2stream.once("headers", cb);
  return () => clienthttp2stream.removeEventListener("headers", cb);
};

// https://nodejs.org/docs/latest/api/http2.html#event-push
export const oncePush = clienthttp2stream => callback => () => {
  const cb = (headers,flags) => callback(headers)(flags)();
  clienthttp2stream.once("push", cb);
  return () => clienthttp2stream.removeEventListener("push", cb);
};
