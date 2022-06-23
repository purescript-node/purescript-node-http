
export const localSettings = http2session => () => {
  return http2session.localSettings;
}

// https://nodejs.org/docs/latest/api/http2.html#http2streamrespondheaders-options
export const respond = http2stream => headers => options => () => {
  http2stream.respond(headers,options);
};

// https://nodejs.org/docs/latest/api/http2.html#http2sessionclosecallback
export const closeSession = http2session => callback => () => {
  if (http2session.closed) {
    callback();
  }
  else {
    http2session.close(() => callback());
  }
};

// https://nodejs.org/docs/latest/api/http2.html#serverclosecallback
export const closeServer = http2server => callback => () => {
  http2server.close(() => callback());
};

// https://nodejs.org/docs/latest/api/http2.html#event-close_1
export const onceClose = http2stream => callback => () => {
  const cb = () => callback(http2stream.rstCode)();
  http2stream.once("close", cb);
  return () => {http2stream.removeEventListener("close", cb);};
};

// https://nodejs.org/docs/latest/api/http2.html#event-stream
export const onceStream = foreign => callback => () => {
  const cb = (stream, headers, flags) => callback(stream)(headers)(flags)();
  foreign.once("stream", cb);
  return () => {foreign.removeListener("stream", cb);};
};

// https://nodejs.org/docs/latest/api/http2.html#event-stream
export const onStream = foreign => callback => () => {
  const cb = (stream, headers, flags) => callback(stream)(headers)(flags)();
  foreign.on("stream", cb);
  return () => {foreign.removeListener("stream", cb);};
};

// https://nodejs.org/docs/latest/api/events.html#nodeeventtargetoncetype-listener-options
export const onceError = eventtarget => callback => () => {
  const cb = error => callback(error)();
  eventtarget.once("error", cb);
  return () => {eventtarget.removeEventListener("error", cb);};
};

// https://nodejs.org/docs/latest/api/net.html#event-close
export const onceServerClose = server => callback => () => {
  const cb = () => callback();
  server.once("close", cb);
  return () => {server.removeEventListener("close", cb);};
};

// https://nodejs.org/docs/latest/api/events.html#emitteronceeventname-listener
export const onceEmitterError = eventemitter => callback => () => {
  const cb = error => callback(error)();
  eventemitter.once("error", cb);
  return () => {eventemitter.removeListener("error", cb);};
};

export const onEmitterError = eventemitter => callback => () => {
  const cb = error => callback(error)();
  eventemitter.on("error", cb);
  return () => {eventemitter.removeListener("error", cb);};
};

export const throwAllErrors = eventtarget => () => {
  eventtarget.addEventListener("error", error => {throw error;});
};

export const onceWantTrailers = http2stream => callback => () => {
  const cb = () => callback();
  http2stream.once("wantTrailers", cb);
  return () => {http2stream.removeEventListener("wantTrailers", cb);};
};

// https://nodejs.org/docs/latest/api/http2.html#http2streamsendtrailersheaders
export const sendTrailers = http2stream => headers => () => {
  http2stream.sendTrailers(headers);
};

export const onceTrailers = http2stream => callback => () => {
  const cb = (headers,flags) => callback(headers)(flags)();
  http2stream.once("trailers", cb);
  return () => {http2stream.removeEventListener("trailers", cb);};
};

export const onData = http2stream => callback => () => {
  const cb = chunk => callback(chunk)();
  http2stream.on("data", cb);
  return () => {http2stream.removeEventListener("data", cb);};
};

export const onceEnd = netsocket => callback => () => {
  const cb = () => callback();
  netsocket.once("end", cb);
  return () => {netsocket.removeListener("end", cb);};
};

export const session = http2stream => {
  return http2stream.session;
};

// https://nodejs.org/docs/latest/api/http2.html#http2streamclosecode-callback
export const closeStream = http2stream => code => callback => () => {
  http2stream.close(code, () => callback());
};
