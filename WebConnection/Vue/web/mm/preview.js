var te = window.previewer = {
    mmEditor: null,
    isPreviewEditorSync: false,
    codeScrolled: new Date().getTime() + 2500,
    highlightTimeout: 1800
};
var isDebug = false;

// This function is global and called by the parent
// to pass in the form object and pass back the text
// editor instance that allows the parent to make
// calls into this component
function initializeinterop(editor) {
    if (window.dotnetProxy) {
        te.mmEditor = window.dotnetProxy;
    } else
        te.mmEditor = editor;

    te.isPreviewEditorSync = te.mmEditor.isPreviewToEditorSync();
    scroll();

}

$(document).ready(function() {
    highlightCode();

    // navigate all links externally in default browser
    $(document).on("click",
        "a",
        function(e) {
            var url = this.href;
            var rawHref = $(this).attr("href");
            var hash = this.hash;

            // Notify of link navigation and handle external urls
            // if not handled elsewhere
            if (te.mmEditor && te.mmEditor.PreviewLinkNavigation(url, rawHref)) {
                // it true editor handled the navigation
                e.preventDefault();
                return false;
            }

            if (hash) {
                var sel = "a[name='" + hash.substr(1) + "'],#" + hash.substr(1);
                var $el = $(sel);
                $("html,body").scrollTop($el.offset().top - 100);
                return false;
            }
        });
    // definition lists
    $(document).on("click",
        "dt",
        function() {
            $(this).nextUntil("dt").toggle();
        });
});

$(document).on("contextmenu",
    function (e) {
        var parm = { Top: 1, Left: 1, Id: '', Type: '', Src:'', Href: '' };

        if (e.target) {
            parm.Id = e.target.id;
            parm.Type = e.target.nodeName;

            if (e.target.src)
                parm.Src = e.target.src;
            if (e.target.href)
                parm.Href = $(e.target).attr("href");
        }
        
        if (te.mmEditor) {
            te.mmEditor.previewContextMenu(parm);
            return false;
        }
        return true;
        // inside of WebBrowser control don't show context menu
        //return navigator.userAgent.indexOf("Trident") > -1 ? false : true;
    });

window.ondrop = function (event) {
    // don't allow dropping here - we can't get full file info
    event.preventDefault();
    event.stopPropagation();

    setTimeout(function () {
        alert("To open dropped files in Markdown Monster, please drop files onto the header area of the window.");
    }, 50);
}

window.ondragover = function (event) {
    event.preventDefault();
    return false;
}

var scroll = debounce(function (event) {

    if (!te.mmEditor || !te.isPreviewEditorSync) return;

    // prevent repositioning editor scroll sync
    // when selecting line in editor (w/ two way sync)
    // te.codeScrolled is set in scrollToPragmaLines so that we don't
    // re-navigate
    var t = new Date().getTime();
    if (te.codeScrolled > t - 970)
        return;

    var st = $(window).scrollTop();
    if (st < 3) {
        te.mmEditor.gotoLine(0, true);
        return;
    }

    var winTop = st + 100;
    var $lines = $("[id*='pragma-line-']");

    if ($lines.length < 1)
        return;

    var id = null;
    for (var i = 0; i < $lines.length; i++) {

        if ($($lines[i]).position().top >= winTop) {
            id = $lines[i].id;
            break;
        }
    }
    if (!id)
        return;

    id = id.replace("pragma-line-", "");

    var line = (id * 1) - 1;
    te.mmEditor.gotoLine(line, true);

},100);
window.onscroll = scroll;

function highlightCode(lineno) {

    var pres = document.querySelectorAll("pre>code");

    // Try to find lineno in doc - if lineno is passed
    // and render only those plus padding above and below
    var linePos = 0;
    if (lineno && pres.length > 200) {
        var $el = $("#pragma-line-" + lineno);
        if ($el.length < 1) {
            for (var j = 0; j < 10; j++) {
                if (lineno - j < 0)
                    break;
                var $el = $("#pragma-line-" + (lineno - j) );
                if ($el.length > 0)
                    break;
            }
            if ($el.length < 1) {
                for (var k = 0; k < 10; k++) {
                    var $el = $("#pragma-line-" + (lineno + k) );
                    if ($el.length > 0)
                        break;
                }
            }
        }
        if ($el.length > 0) {
            linePos = $el.position().top;
        }
    }
    //console.log("Line Pos:" + linePos + " " + lineno + " " + $el);

    for (var i = 0; i < pres.length; i++) {
        var block = pres[i];
        var $code = $(block);

        // too many code blocks to render or text/plain styles - just style
        if ((pres.length > 400) ||
            $code.hasClass("language-text") ||
            $code.hasClass("language-plain")) {
                $code.addClass("hljs");
                continue;
        }

        // render only matched lines that are in viewport + padding
        if (linePos > 0) {
            var top = $code.position().top;

            if (top < linePos - 2000) {
                //console.log("Skipping smaller: " + top, linePos);
                //$code.addClass("hljs");
                continue;
            }
            if (top > linePos + 2000) {
                //console.log("Breaking larger: " + top, linePos);
                //$code.addClass("hljs");
                break;
            }
        }

        hljs.highlightBlock(block);

        // This is better for perf but makes the preview jumpy
        //setTimeout(function(bl) {
        //    hljs.highlightBlock(bl);
        //}.bind(this, block));
    }

    // add the code snippet syntax and code copying
    if (highlightJsBadge)  highlightJsBadge();
}

// this works, but async updates of code blocks is too jumpy
//function highlightCodeWebWorker() {
//    var script = document.getElementById("PreviewScript");

//    if (!script) {
//        alert('PReviewScript tag not found');
//        return;
//    }

//    script = script.src.replace("/preview.js", "/highlightJsWorker.js");
//    console.log(script);


//    $("pre code")
//        .each(function (i, block) {
//            var $block = $(block);
//            var code = $block.text().trimEnd();

//            console.log("worker loaded", worker);

//            var worker = new Worker(script);
//            worker.onmessage = function (event) {
//                var result = event.data;
//                console.log("Result: ", result.value);
//                $block[0].outerHTML =
//                    '<code class="language-javascript" id="pragma-line-8">' + result.value + '</code>'; //html( result.value );

//                worker.terminate();
//                console.log("done in web worker response");
//            };
//            var lang = $block.attr("class");
//            if (lang)
//                lang = lang.replace("language-", "");

//            var d = {
//                code: code,
//                lang: lang,
//                script: script.replace("/highlightJsWorker.js", "/highlightjs/highlight.pack.js")
//            };
//            worker.postMessage(d);
//            console.log("PostMessage called", d);
//        });
//}

function updateDocumentContent(html, lineno) {
  //console.log('update document content');
  te.isPreviewEditorSync = te.mmEditor.isPreviewToEditorSync();
  // console.log("Assigning html before Timeout " + new Date().getTime());

  var el = document.getElementById("MainContent");
  if (!el)
    return;
  el.innerHTML = html;

  highlightCode(lineno);

  // Raise a previewUpdated event on the document
  var event = document.createEvent("Event");
  event.initEvent("previewUpdated", false, true);

  event.target = el;
  event.currentTarget = el;
  document.dispatchEvent(event);
}

function scrollToPragmaLine(lineno) {
  if (typeof lineno !== "number" || lineno < 0) return;

  setTimeout(function() {
      if (lineno < 3) {
        $("html").scrollTop(0);
        return;
      }

      try {
        var $el = $("#pragma-line-" + lineno);
        if ($el.length < 1) {
          var origLine = lineno;

          // try forward with 3 lines
          for (var i = 0; i < 3; i++) {
            lineno++;
            $el = $("#pragma-line-" + lineno);
            if ($el.length > 0)
              break;
          }
          // try backwards with 3 lines
          if ($el.length < 1) {
            lineno = origLine;
            for (var i = 0; i < 3; i++) {
              lineno--;
              $el = $("#pragma-line-" + lineno);
              if ($el.length > 0)
                break;
            }
          }
          if ($el.length < 1)
            return;
        }

        $el.addClass("line-highlight");
        if (te.highlightTimeout > 0)
          setTimeout(function() { $el.removeClass("line-highlight"); }, te.highlightTimeout);

        te.codeScrolled = new Date().getTime();
        if (lineno > 3)
          $("html").scrollTop($el.offset().top - 150);
      } catch (ex) {
      }
    },
    20);
}

function getScrollTop() {

    var st = document.documentElement.scrollTop;
    if (!st)
        return 0;
    return st;
}

function status(msg,append) {
    var $el = $("#statusmessage");
    if ($el.length < 1) {
        $el = $("<div id='statusmessage' style='position: fixed; opacity: 0.8; left:0; right:0; bottom: 0; padding: 5px 10px; background: #444; color: white;'></div>");
        $(document.body).append($el);
    }

    if (append) {
        var html = $el.html() +
            "<br/>" +
            msg;
        $el.html(html);
    }
    else
        $el.text(msg);

    $el.show();
    setTimeout(function() { $el.text(""); $el.fadeOut() }, 6000);
}


window.xonerror = function windowError(message, filename, lineno, colno, error) {
    if (!isDebug)
        return true;

    var msg = "";
    if (message)
        msg = message;
    //if (filename)
    //    msg += ", " + filename;
    if (lineno)
        msg += " (" + lineno + "," + colno + ")";
    if (error)
        msg += error;

    // show error messages in a little pop overwindow
    if (isDebug)
        status(msg);

    console.log("Error: " + msg);

    // don't let errors trigger browser window
    return true;
}

function debounce(func, wait, immediate) {
    var timeout;
    return function () {
        var context = this, args = arguments;
        var later = function () {
            timeout = null;
            if (!immediate) func.apply(context, args);
        };
        var callNow = immediate && !timeout;
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
        if (callNow)
            func.apply(context, args);
    };
};



/* ES5 POLYFILLS */

// String.trim() for ES5 polyfill
if (!String.prototype.trim) {
    String.prototype.trim = function () {
        return this.replace(/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g, '');
    };
}

if (!String.prototype.trimEnd) {
    String.prototype.trimEnd = function (c) {
        if (c)
            return this.replace(new RegExp(c.escapeRegExp() + "*$"), '');
        return this.replace(/\s+$/, '');
    };
}

if (!String.prototype.startsWith) {
    Object.defineProperty(String.prototype, 'startsWith', {
        value: function (search, rawPos) {
            pos = rawPos > 0 ? rawPos | 0 : 0;
            return this.substring(pos, pos + search.length) === search;
        }
    });
}

// Object.assign() for ES5 polyfill
if (typeof Object.assign !== 'function') {
    // Must be writable: true, enumerable: false, configurable: true
    Object.defineProperty(Object, "assign", {
        value: function assign(target, varArgs) { // .length of function is 2
            'use strict';
            if (target === null || target === undefined) {
                throw new TypeError('Cannot convert undefined or null to object');
            }

            var to = Object(target);

            for (var index = 1; index < arguments.length; index++) {
                var nextSource = arguments[index];

                if (nextSource !== null && nextSource !== undefined) {
                    for (var nextKey in nextSource) {
                        // Avoid bugs when hasOwnProperty is shadowed
                        if (Object.prototype.hasOwnProperty.call(nextSource, nextKey)) {
                            to[nextKey] = nextSource[nextKey];
                        }
                    }
                }
            }
            return to;
        },
        writable: true,
        configurable: true
    });
}

