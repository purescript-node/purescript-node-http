export const pathImpl = (cr) => cr.path;
export const methodImpl = (cr) => cr.method;
export const hostImpl = (cr) => cr.host;
export const protocolImpl = (cr) => cr.protocol;
export const reusedSocketImpl = (cr) => cr.reusedSocket;
export const setNoDelayImpl = (d, cr) => cr.setNoDelay(d);
export const setSocketKeepAliveImpl = (b, ms, cr) => cr.setSocketKeepAlive(b, ms);
export const setTimeoutImpl = (ms, cr) => cr.setTimeout(ms);
