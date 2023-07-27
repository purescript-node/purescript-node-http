import http from "node:http";
import https from "node:https";
export const createServerOnly = () => http.createServer();
export const createSecureServerOnlyImpl = (opts) => https.createServer(opts);
export const onRequestImpl = (server, cb) => server.on("request", cb);
export const stdout = process.stdout;
export const setTimeoutImpl = (int, cb) => setTimeout(cb, int);
