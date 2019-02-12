(function() {

	function sendMsg(msg) {
		sendMessageQueue.push(msg);
		var msgs = _fetchQueue();
		window.webkit.messageHandlers.mpDispatchMessage.postMessage(msgs);
	}

	function _fetchQueue() {
		if (jsbridge._fetchQueue !== _fetchQueue) return "";
		var msgQStr = JSON.stringify(sendMessageQueue);
		sendMessageQueue = [];
		var dicMsg = {};
		dicMsg["__msg_queue"] = msgQStr;
        return JSON.stringify(dicMsg);
	}

	function _handleMessageFromMP(dic) {
		if (jsbridge._handleMessageFromMP !== _handleMessageFromMP) return "{}";
		var jsonMsg = dic[ "__json_message" ];
		var funcDic;
		try {
			funcDic = JSON.parse(jsonMsg)
		}
		catch (err) {
			// TODO
			funcDic = window.JSON.parse(jsonMsg)
		}

		switch (funcDic.__msg_type) {
			case "callback": {
				if ("string" === typeof funcDic.__callback_id && 
					"function" === typeof callbacks[funcDic.__callback_id]) {
					var callback = callbacks[funcDic.__callback_id](funcDic.__params);
					delete callbacks[funcDic.__callback_id];
					return JSON.stringify(callback);
				}
				else {
					return JSON.stringify({
                		__err_code: "cb404"
            		});
				}
			};
			case "event": {
				if ("object" === typeof funcDic.__runOn3rd_apis) {
					runOn3rdApis = funcDic.__runOn3rd_apis;
				}
				if ("string" === typeof funcDic.__event_id) {
					if ("function" === typeof eventMap[funcDic.__event_id]) {
						var d = eventMap[funcDic.__event_id](funcDic.__params);
						return JSON.stringify(d);
					}
					if ("function" === typeof funcMap[funcDic.__event_id]) {
						var d = funcMap[funcDic.__event_id](funcDic.__params);
						return JSON.stringify(d);
					}
				}
				return JSON.stringify({
                	__err_code: "ev404"
            	})
			};
		}
		return "{}";
	}

	function log(c) {
		if (jsbridge.log === log) {
			for (var d = [], a = 0; a < arguments.length; a++) d.push(arguments[a]);
			var a = d.shift(), b;
            try {
                d.unshift(a),
                b = Q.apply(null, d)
            } catch(e) {
                b = c
            }
            call("log", { msg: b});
		}
	}

	function call(func, params, callback) {
		if ("preInject" === document.__mpjsjs__isPreInject && !0 !== document.mpjsSysinit) {
			var cb = {};
			cb.params = params;
			cb.callback = callback;
			waitingQueue[func] = cb;
		}
		else if (jsbridge.call === call && func && "string" === typeof func) {
			if ("object" !== typeof params) {
				if ("string" === typeof params) {
                    var v = params;
                    params = {"params": v};
                }
                else {
                    params = {};
                }
			}
			var callbackId = (id++).toString();
			if ("function" === typeof callback) {
				callbacks[callbackId] = callback;
			}

			var funcDic = {
				"func" : func,
				"params" : params
			};
			funcDic[ "__msg_type" ] = "call";
			funcDic[ "__callback_id" ] = callbackId;

			sendMsg(JSON.stringify(funcDic));
		}
	}

	function defineFunc(name, func) {
		if (name && "string" === typeof name && "function" === typeof func) {
			funcMap[name] = func;
		}
	}

	function on(event, callback) {
		if (jsbridge.on == on) {
			if (event && "string" === typeof event && "function" === typeof callback) {
				eventMap[event] = callback;
			}
		}
	}

	var Q = function() {
        function c(a) {
            return Object.prototype.toString.call(a).slice(8, -1).toLowerCase()
        }
        var d = function() {
            d.cache.hasOwnProperty(arguments[0]) || (d.cache[arguments[0]] = d.parse(arguments[0]));
            return d.format.call(null, d.cache[arguments[0]], arguments)
        };
        d.format = function(a, b) {
            var d = 1,
            o = a.length,
            i = "",
            j = [],
            k,
            m,
            l,
            r;
            for (k = 0; k < o; k++) if (i = c(a[k]), "string" === i) j.push(a[k]);
            else if ("array" === i) {
                l = a[k];
                if (l[2]) {
                    i = b[d];
                    for (m = 0; m < l[2].length; m++) {
                        if (!i.hasOwnProperty(l[2][m])) throw Q('[sprintf] property "%s" does not exist', l[2][m]);
                        i = i[l[2][m]]
                    }
                } else i = l[1] ? b[l[1]] : b[d++];
                if (/[^s]/.test(l[8]) && "number" != c(i)) throw Q("[sprintf] expecting number but found %s", c(i));
                switch (l[8]) {
                case "b":
                    i = i.toString(2);
                    break;
                case "c":
                    i = String.fromCharCode(i);
                    break;
                case "d":
                    i = parseInt(i, 10);
                    break;
                case "e":
                    i = l[7] ? i.toExponential(l[7]) : i.toExponential();
                    break;
                case "f":
                    i = l[7] ? parseFloat(i).toFixed(l[7]) : parseFloat(i);
                    break;
                case "o":
                    i = i.toString(8);
                    break;
                case "s":
                    i = (i = "" + i) && l[7] ? i.substring(0, l[7]) : i;
                    break;
                case "u":
                    i = Math.abs(i);
                    break;
                case "x":
                    i = i.toString(16);
                    break;
                case "X":
                    i = i.toString(16).toUpperCase()
                }
                i = /[def]/.test(l[8]) && l[3] && 0 <= i ? "+" + i: i;
                m = l[4] ? "0" == l[4] ? "0": l[4].charAt(1) : " ";
                r = l[6] - ("" + i).length;
                if (l[6]) {
                    for (var n = []; 0 < r; n[--r] = m);
                    m = n.join("")
                } else m = "";
                j.push(l[5] ? i + m: m + i)
            }
            return j.join("")
        };
        d.cache = {};
        d.parse = function(a) {
            for (var b = [], c = [], d = 0; a;) {
                if (null !== (b = /^[^\x25]+/.exec(a))) c.push(b[0]);
                else if (null !== (b = /^\x25{2}/.exec(a))) c.push("%");
                else if (null !== (b = /^\x25(?:([1-9]\d*)\$|\(([^\)]+)\))?(\+)?(0|'[^$])?(-)?(\d+)?(?:\.(\d+))?([b-fosuxX])/.exec(a))) {
                    if (b[2]) {
                        var d = d | 1,
                        i = [],
                        j = b[2],
                        k = [];
                        if (null !== (k = /^([a-z_][a-z_\d]*)/i.exec(j))) for (i.push(k[1]);
                        "" !== (j = j.substring(k[0].length));) if (null !== (k = /^\.([a-z_][a-z_\d]*)/i.exec(j))) i.push(k[1]);
                        else if (null !== (k = /^\[(\d+)\]/.exec(j))) i.push(k[1]);
                        else throw "[sprintf] huh?";
                        else throw "[sprintf] huh?";
                        b[2] = i
                    } else d |= 2;
                    if (3 === d) throw "[sprintf] mixing positional and named placeholders is not (yet) supported";
                    c.push(b)
                } else throw "[sprintf] huh?";
                a = a.substring(b[0].length)
            }
            return c
        };
        return d
    } ();

    var oalert = window.alert;
	window.alert = function(text) {
		if (! ("yes" === document.__mpjsjs__isWebviewWillClosed ||
			   "yes" === document.__mpjsjs__isDisableAlertView)) {
			return oalert(text);
		}
	};
	var oprompt = window.prompt;
	window.prompt = function(text, defaultText) {
        if (! ("yes" === document.__mpjsjs__isWebviewWillClosed || 
        	   "yes" === document.__mpjsjs__isDisableAlertView)) {
        	return oprompt(text, defaultText);
        } 
    };
    var sendMessageQueue = [];
    var callbacks = {};
    var funcMap = {};
    var waitingQueue = [];
    var eventMap = {};
    var z = {};
    var runOn3rdApis = [];
    var id = 1E3;
    // var contextKey = "";
    // var secretKey = "xx_yy";
    var jsbridge = {
    	invoke: call,
    	call: call,
    	on: on,
    	log: log,
    	// _getSelectedText: ,
    	_fetchQueue: _fetchQueue,
    };
    try {
    	Object.defineProperty(jsbridge, "_handleMessageFromMP", {
    		value: _handleMessageFromMP,
            writable: false,
            configurable: false
    	})
    } 
    catch(err) {
    	return;
    }
    if (window.MPJSBridge) { 
    	window.MPJSBridge = jsbridge;
    }
    else {
    	try {
	        Object.defineProperty(window, "MPJSBridge", {
	            value: jsbridge,
	            writable: false,
	            configurable: false
	        })
	    } catch(sa) {
	        return
	    }
    }

    // ======= Start Adpat for webviewJSBridge =======
    var webjsbridge = {
    	callHandler: call,
    	registerHandler: on,
    };
    if (window.WebViewJavascriptBridge) { 
    	window.WebViewJavascriptBridge = webjsbridge;
    }
    else {
    	try {
	        Object.defineProperty(window, "WebViewJavascriptBridge", {
	            value: webjsbridge,
	            writable: false,
	            configurable: false
	        })
	    } catch(sa) {
	        return
	    }
    }
    // ======= End Adpat for webviewJSBridge =======

    (function() {
		defineFunc("sys:init",
        	function(a) {
	            z = a;
	            a = document.createEvent("Events");
	            a.initEvent("MPJSBridgeReady");
	            document.dispatchEvent(a);
	            // ======= Start Adpat for webviewJSBridge =======
	            a = document.createEvent("Events");
	            a.initEvent("WebViewJavascriptBridgeReady");
	            document.dispatchEvent(a);
	            // ======= End Adpat for webviewJSBridge =======
	            if ("preInject" === document.__mpjsjs__isPreInject) {
	                document.mpjsSysinit = true;
	                for (var b in waitingQueue) {
	                	a = waitingQueue[b];
	                	call(b, a.params, a.callback);
	                }
	                waitingQueue = [];
	            }
        });
	})();
})();
window.__mpjs_is_injected_success = "yes";
