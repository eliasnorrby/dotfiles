#!/bin/sh
# Open a linear.app URL in the installed Linear PWA window (work profile).
#
# Chrome ignores URL args passed to --app-id (it always opens the app's home),
# and --app spawns a separate window keyed by the URL, which falls outside the
# workspace/focus rules built around the PWA's window class. Instead we hand the
# URL to the work browser and let Chrome's link capturing ("Open supported links
# in app", toggled per-app in chrome://apps -> Linear) route it into the running
# PWA window and navigate it there.
exec chrome-work "$1"
