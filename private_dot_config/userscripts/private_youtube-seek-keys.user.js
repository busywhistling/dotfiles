// ==UserScript==
// @name         YouTube - F7/F9 seek +/-5s
// @namespace    local.paramjit.youtube-seek-keys
// @version      1.0.0
// @description  Turns the media Previous/Next Track keys (F7/F9) into a 5s seek in YouTube, without stealing focus from whatever app you are typing in.
// @author       paramjit
// @match        https://www.youtube.com/*
// @run-at       document-start
// @grant        none
// @noframes
// ==/UserScript==

(function () {
  'use strict';

  if (window.__ytSeekKeysFinished) return;
  window.__ytSeekKeysFinished = true;

  const STEP = 5;
  const VERSION = '1.0.0';

  function primaryVideo() {
    const vids = Array.from(document.querySelectorAll('video'));
    return (
      vids.find((v) => v.classList.contains('html5-main-video')) ||
      vids.find((v) => !v.paused) ||
      vids[0] ||
      null
    );
  }

  function isAd() {
    const player = document.querySelector('.html5-video-player');
    return !!(player && player.classList.contains('ad-showing'));
  }

  function seek(delta) {
    if (isAd()) return;
    const v = primaryVideo();
    if (!v) return;

    let lo = 0;
    let hi = Number.isFinite(v.duration) ? v.duration : Infinity;
    try {
      if (v.seekable && v.seekable.length > 0) {
        lo = v.seekable.start(0);
        hi = v.seekable.end(v.seekable.length - 1);
      }
    } catch (e) {
      /* live edge changing under us - fall back to duration bounds */
    }

    const target = Math.min(hi, Math.max(lo, v.currentTime + delta));
    if (Number.isFinite(target)) v.currentTime = target;
  }

  // The media keys arrive as Media Session actions, the same channel F8 (play/pause) uses.
  const handlers = new Map([
    ['previoustrack', () => seek(-STEP)],
    ['nexttrack', () => seek(STEP)],
    ['seekbackward', () => seek(-STEP)],
    ['seekforward', () => seek(STEP)],
  ]);

  function register() {
    const ms = navigator.mediaSession;
    if (!ms) return;
    handlers.forEach((fn, action) => {
      try {
        ms.setActionHandler(action, fn);
      } catch (e) {
        /* action unsupported in this build */
      }
    });
  }

  // Make YouTube's own registrations go through us so we are never silently clobbered
  // (SPA navigation, ad -> content, player re-init). No-op if we ended up in an
  // isolated world, in which case re-registering below covers it.
  try {
    const proto = window.MediaSession && window.MediaSession.prototype;
    if (proto && !proto.__ytSeekKeys) {
      const orig = proto.setActionHandler;
      if (typeof orig === 'function') {
        proto.setActionHandler = function (action, handler) {
          const ours = handlers.get(action);
          return orig.call(this, action, ours === undefined ? handler : ours);
        };
        proto.__ytSeekKeys = true;
      }
    }
  } catch (e) {
    /* page world not available - layer 1 only */
  }

  register();
  if (document.documentElement) {
    document.documentElement.dataset.ytSeekKeys = VERSION;
  }

  const reRegister = () => register();
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', reRegister, { once: true });
  } else {
    reRegister();
  }
  window.addEventListener('yt-navigate-finish', reRegister, true);
  document.addEventListener('play', reRegister, true);
  document.addEventListener('loadedmetadata', reRegister, true);
})();
