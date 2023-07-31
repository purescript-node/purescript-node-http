import http from "node:http";

export const createServer = () => http.createServer();
export const createServerOptsImpl = (opts) => http.createServer(opts);

export const maxHeaderSize = http.maxHeaderSize;

export const requestImpl = (url) => http.request(url);
export const requestUrlOptsImpl = (url, opts) => http.request(url, opts);
export const requestOptsImpl = (opts) => http.request(opts);

export const getImpl = (url) => http.get(url);
export const getUrlOptsImpl = (url, opts) => http.get(url, opts);
export const getOptsImpl = (opts) => http.get(opts);

export const setMaxIdleHttpParsersImpl = (i) => http.setMaxIdleHTTPParsers(i);
