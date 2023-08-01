export const bytesParsed = (e) => e.bytesParsed;
export const rawPacket = (e) => e.rawPacket;

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
