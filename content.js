(function () {
  "use strict";
  var discord = /^https?:\/\/(?:[^/]+\.)?(?:discord\.com|discordapp\.com)(?:\/|$)/i;

  function isExternal(url) {
    return /^https?:\/\//i.test(url) && !discord.test(url);
  }

  function linkFrom(target) {
    while (target && target.nodeType === 1 && target.tagName !== "A") {
      target = target.parentNode;
    }
    return target && target.tagName === "A" ? target : null;
  }

  document.addEventListener("click", function (event) {
    var link = linkFrom(event.target);
    if (!link || !isExternal(link.href)) return;
    event.preventDefault();
    event.stopPropagation();
    browser.runtime.sendMessage({ type: "external-link", url: link.href });
  }, true);

  document.addEventListener("auxclick", function (event) {
    if (event.button !== 1) return;
    var link = linkFrom(event.target);
    if (!link || !isExternal(link.href)) return;
    event.preventDefault();
    browser.runtime.sendMessage({ type: "external-link", url: link.href });
  }, true);
}());
