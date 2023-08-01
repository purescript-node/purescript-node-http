export const path = (cr) => cr.path;
export const method = (cr) => cr.method;
export const host = (cr) => cr.host;
export const protocol = (cr) => cr.protocol;
export const reusedSocket = (cr) => cr.reusedSocket;
export const setNoDelayImpl = (d, cr) => cr.setNoDelay(d);
export const setSocketKeepAliveImpl = (b, ms, cr) => cr.setSocketKeepAlive(b, ms);
export const setTimeoutImpl = (ms, cr) => cr.setTimeout(ms);
