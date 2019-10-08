/// <reference path="jquery.js" />
/// <reference path="ww.jquery.js" />
/*
ww.jQuery.js  
Version 1.11 - 1/2/2014
West Wind jQuery plug-ins and utilities

(c) 2008-2014 Rick Strahl, West Wind Technologies 
www.west-wind.com

Licensed under MIT License
http://en.wikipedia.org/wiki/MIT_License
*/
(function($, undefined) {
    ww = {};
    ww.angular = {
        parseHttpError: function(args) {
            var data = args[0]; // http data
            var status = args[1];  // error code
            var msg = args[2];  // ???
			var $http = args[3] // object with http props
            var errorMsg = "";

            if (data) {
                try {
                    var msg = JSON.parse(data);

                    if (msg && msg.hasOwnProperty("message") || msg.hasOwnProperty("Message"))
                        return msg;
                } catch (exception) {
                    return new CallbackException("Unknown error.");
                }
            }

            return new CallbackException(errorMsg);
        },
        // extends deferred with .success and .error functions
        deferredExtender: function(deferred) {
            deferred.success = function(fn) {
                deferred.promise.then(fn);
                return deferred;
            };
            deferred.error = function(fn) {
                deferred.promise.then(null,fn);
                return deferred;
            };
            return deferred;
        }

    };

})(jQuery);