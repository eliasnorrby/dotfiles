#!/bin/sh

class=$(xprop | grep WM_CLASS | cut -d "," -f2)
echo "${class#*= }"
