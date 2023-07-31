import https from "node:https";

export const createSecureServer = () => https.createServer();
export const createSecureServerOptsImpl = (opts) => https.createServer(opts);

export const requestImpl = (url) => https.request(url);
export const requestUrlOptsImpl = (url, opts) => https.request(url, opts);
export const requestOptsImpl = (opts) => https.request(opts);

export const getImpl = (url) => https.get(url);
export const getUrlOptsImpl = (url, opts) => https.get(url, opts);
export const getOptsImpl = (opts) => https.get(opts);
