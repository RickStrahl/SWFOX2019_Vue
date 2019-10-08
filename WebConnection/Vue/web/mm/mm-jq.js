/// Make sure this is run AFTER highlightJs and delayed a bit
/// so it can operate AFTER the hljs classes have been added.
(function () {
   
    var templateSelector = "#CodeHudTemplate";
    var contentSelector = "#MainContent";    

    if ($)
        $(addCodeHud);
    else        
        setTimeout(addCodeHud,100);

    function addCodeHud() {
        var $codes = $("pre>code.hljs");
        var hudText = $(templateSelector).html();

        $codes.each(function () {
            var $el = $(this);
            var lang = "";
            var classList = $el.attr('class').split(/\s+/);
            
            for (var i = 0; i < classList.length; i++) {
                if (classList[i].substr(0, 9) === 'language-') {
                    lang = classList[i].replace('language-', '');
                    break;
                }
            }
            if (lang)
                lang = lang.toLowerCase();

            // fix up a few common shortcuts    
            if (lang == "ps")
                lang = "powershell";
            else if (lang == "cs")
                lang = "csharp";
            else if (lang == "js")
                lang = "javascript"
            else if (lang == "ts")
                lang = "typescript"
            else if (lang == "fox")
                lang = "foxpro"

            var html = hudText.replace("{{lang}}", lang);
            console.log(html);
            var $newHud = $(html);
            $el.prepend($newHud);
        });

        $(contentSelector).on("click", ".code-hud>a", copyCodeToClipboard);
    }

    function copyCodeToClipboard() {
        var $el = $(this).parents("code");
        var $elHud = $el.find(".code-hud");
        if ($el.length < 1)
            return;
            
        // we have to clear out the .code-hud - clone and remove
        var $code = $el.clone();        
        var $hud = $code.find(".code-hud");
        $hud.html("");
        
        var text = $code.text();
        var el = document.createElement('textarea');
        el.value = text;
        document.body.appendChild(el);
        el.select();

        document.execCommand('copy');
        document.body.removeChild(el);

        
        $elHud.find(".fa").removeClass("fa-copy").addClass("fa-check");
        setTimeout(function() { $elHud.find(".fa").removeClass("fa-check").addClass("fa-copy"); },1800);
    }
})();

