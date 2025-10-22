#!/usr/bin/env bash

curl http://localhost:3000/api-json -s >api.json
~/.local/share/nvim/mason/bin/kulala-fmt convert api.json

node merge-http.js
