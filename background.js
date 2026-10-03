(function () {
  "use strict";

  var HOST = "discord_client";
  var discord = /^https?:\/\/(?:[^/]+\.)?(?:discord\.com|discordapp\.com)(?:\/|$)/i;

  function isExternal(url) {
    return typeof url === "string" && !discord.test(url);
  }

  function openExternal(url) {
    if (!isExternal(url)) return;
    browser.runtime.sendNativeMessage(HOST, { url: url }).catch(function () {});
  }

  browser.runtime.onMessage.addListener(function (message) {
    if (!message || message.type !== "external-link") return;
    openExternal(message.url);
  });

  browser.downloads.onCreated.addListener(function (download) {
    if (!download || !isExternal(download.url)) return;
    browser.downloads.cancel(download.id).catch(function () {});
    openExternal(download.url);
  });
}());
