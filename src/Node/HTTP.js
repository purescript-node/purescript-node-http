import http from "node:http";

export const createServer = () => http.createServer();
export const createServerOptsImpl = (opts) => http.createServer(opts);

export const maxHeaderSize = http.maxHeaderSize;

export const requestImpl = (url) => http.request(url);
export const requestOptsImpl = (url, opts) => http.request(url, opts);

export const getImpl = (url) => http.get(url);
export const getOptsImpl = (url, opts) => http.get(url, opts);

export const setMaxIdleHttpParsersImpl = (i) => http.setMaxIdleHTTPParsers(i);
