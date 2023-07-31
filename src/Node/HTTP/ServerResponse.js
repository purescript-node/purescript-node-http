export const req = (sr) => sr.req;

export const sendDateImpl = (sr) => sr.sendDate;
export const setSendDateImpl = (d, sr) => {
  sr.sendDate = d;
};
export const statusCodeImpl = (sr) => sr.statusCode;
export const setStatusCodeImpl = (code, sr) => {
  sr.statusCode = code;
};
export const statusMessageImpl = (sr) => sr.statusMessage;
export const setStatusMessageImpl = (msg, sr) => {
  sr.statusMessage = msg;
};
export const strictContentLengthImpl = (sr) => sr.strictContentLength;
export const setStrictContentLengthImpl = (b, sr) => {
  sr.strictContentLength = b;
};

export const writeEarlyHintsImpl = (hints, sr) => sr.writeEarlyHints(hints);
export const writeEarlyHintsCbImpl = (hints, cb, sr) => sr.writeEarlyHintsCb(hints, cb);

export const writeHeadImpl = (code, sr) => sr.writeHead(code);
export const writeHeadMsgImpl = (code, msg, sr) => sr.writeHeadMsg(code, msg);
export const writeHeadHeadersImpl = (code, hdrs, sr) => sr.writeHeadHeaders(code, hdrs);
export const writeHeadMsgHeadersImpl = (code, msg, hdrs, sr) => sr.writeHeadMsgHeaders(code, msg, hdrs);

export const writeProcessingImpl = (sr) => sr.writeProcessing();
