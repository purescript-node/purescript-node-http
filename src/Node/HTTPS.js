import https from "node:https";

export const createSecureServer = () => https.createServer();
export const createSecureServerOptsImpl = (opts) => https.createServer(opts);

export const requestStrImpl = (url) => https.request(url);
export const requestStrOptsImpl = (url, opts) => https.request(url, opts);
export const requestUrlImpl = (url) => https.request(url);
export const requestUrlOptsImpl = (url, opts) => https.request(url, opts);
export const requestOptsImpl = (opts) => https.request(opts);

export const getStrImpl = (url) => https.get(url);
export const getStrOptsImpl = (url, opts) => https.get(url, opts);
export const getUrlImpl = (url) => https.get(url);
export const getUrlOptsImpl = (url, opts) => https.get(url, opts);
export const getOptsImpl = (opts) => https.get(opts);
