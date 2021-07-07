#!/bin/sh

class=$(xprop | grep WM_CLASS | cut -d "," -f1)
echo "${class#*= }"
