import http2 from "http2";

export const sensitiveHeaders = h => {
	return {...h, ...{[http2.sensitiveHeaders]: Object.keys(h)}};
};

// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Spread_syntax
export const unionHeadersImpl = l => r => {
	return {...l, ...r}
};
