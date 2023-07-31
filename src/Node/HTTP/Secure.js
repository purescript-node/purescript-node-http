import https from "node:https";

export const createSecureServer = () => https.createServer();
export const createSecureServerOptsImpl = (opts) => https.createServer(opts);

export const requestImpl = (url) => https.request(url);
export const requestUrlOptsImpl = (url, opts) => https.request(url, opts);
export const requestOptsImpl = (opts) => https.request(opts);

export const getImpl = (url) => https.get(url);
export const getUrlOptsImpl = (url, opts) => https.get(url, opts);
export const getOptsImpl = (opts) => https.get(opts);

export const closeAllConnectionsImpl = (hs) => hs.closeAllConnections();
export const closeIdleConnectionsImpl = (hs) => hs.closeIdleConnections();
export const headersTimeoutImpl = (hs) => hs.headersTimeout;
export const setHeadersTimeoutImpl = (tm, hs) => {
  hs.headersTimeout = tm;
};

export const maxHeadersCountImpl = (hs) => hs.maxHeadersCount;
export const setMaxHeadersCountImpl = (c, hs) => {
  hs.maxHeadersCount = c;
};
export const requestTimeoutImpl = (hs) => hs.requestTimeout;
export const setRequestTimeoutImpl = (tm, hs) => {
  hs.requestTimeout = tm;
};
export const maxRequestsPerSocketImpl = (hs) => hs.maxRequestsPerSocket;
export const setMaxRequestsPerSocketImpl = (c, hs) => {
  hs.maxRequestsPerSocket = c;
};
export const timeoutImpl = (hs) => hs.timeout;
export const setTimeoutImpl = (c, hs) => {
  hs.timeout = c;
};
export const keepAliveTimeoutImpl = (hs) => hs.keepAliveTimeout;
export const setKeepAliveTimeoutImpl = (tm, hs) => {
  hs.keepAliveTimeout = tm;
};
