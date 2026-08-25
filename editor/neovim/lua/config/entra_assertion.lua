-- Mints a Microsoft Entra ID client assertion (private_key_jwt, RFC 7521/7523)
-- for kulala's OAuth2 "Client Credentials" grant.
--
-- kulala's own `Client Credentials = "jwt"` mode sends the RFC 7523 §2.1 JWT
-- bearer grant, which Entra does not accept. This builds the assertion instead
-- and leaves the token request to a plain client-credentials config, with the
-- assertion passed through as a custom request parameter.
--
-- Register it as a dynamic variable in the kulala plugin spec:
--
--     custom_dynamic_variables = {
--       ['$entra_assertion'] = function()
--         return require('config.entra_assertion').build()
--       end,
--     },
--
-- then reference it from the auth config in http-client.private.env.json:
--
--     "Security": { "Auth": { "default": {
--       "Type": "OAuth2",
--       "Grant Type": "Client Credentials",
--       "Client Credentials": "none",
--       "Client ID": "{{ENTRA_CLIENT_ID}}",
--       "Client Secret": "unused-with-certificate-auth",
--       "Token URL": "{{ENTRA_TOKEN_URL}}",
--       "Scope": "{{ENTRA_SCOPE}}",
--       "Custom Request Parameters": {
--         "client_id": "{{ENTRA_CLIENT_ID}}",
--         "client_assertion_type": "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
--         "client_assertion": "{{$entra_assertion}}"
--       }
--     } } }
--
-- `Client Secret` is only there to satisfy kulala's field validation; with
-- `Client Credentials = "none"` it is never sent.
local M = {}

local ASSERTION_LIFETIME_SECONDS = 300
local NBF_SKEW_SECONDS = 30

-- Read from the selected kulala environment:
--   ENTRA_TOKEN_URL       https://login.microsoftonline.com/<tenant>/oauth2/v2.0/token
--   ENTRA_CLIENT_ID       client id of the app registration
--   ENTRA_CERT_KEY_PATH   PEM private key whose certificate is registered on that app
--   ENTRA_CERT_THUMBPRINT x5t#S256: unpadded base64url of SHA-256 over the DER cert,
--                         not the SHA-1 thumbprint the Azure portal shows first
local REQUIRED_VARIABLES = {
  'ENTRA_TOKEN_URL',
  'ENTRA_CLIENT_ID',
  'ENTRA_CERT_KEY_PATH',
  'ENTRA_CERT_THUMBPRINT',
}

math.randomseed(os.time() + math.floor(os.clock() * 1000))

local function uuid()
  return (string.gsub('xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx', '[xy]', function(c)
    local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
    return string.format('%x', v)
  end))
end

local function fail(message)
  vim.notify('entra_assertion: ' .. message, vim.log.levels.ERROR)
end

---@return string|nil signed JWT to send as `client_assertion`
function M.build()
  local env = require('kulala.parser.env').get_env() or {}

  local missing = vim.tbl_filter(function(name)
    return (env[name] or '') == ''
  end, REQUIRED_VARIABLES)

  if #missing > 0 then
    return fail('missing environment variables: ' .. table.concat(missing, ', '))
  end

  local key_path = vim.fn.expand(env.ENTRA_CERT_KEY_PATH)
  if vim.fn.filereadable(key_path) == 0 then
    return fail('ENTRA_CERT_KEY_PATH is not readable: ' .. key_path)
  end

  local now = os.time()

  local header = {
    alg = 'RS256', -- kulala signs RS256/HS256 only; Entra accepts RS256
    typ = 'JWT',
    ['x5t#S256'] = env.ENTRA_CERT_THUMBPRINT, -- how Entra finds the registered cert
  }

  local payload = {
    iss = env.ENTRA_CLIENT_ID,
    sub = env.ENTRA_CLIENT_ID,
    aud = env.ENTRA_TOKEN_URL,
    jti = uuid(),
    iat = now,
    nbf = now - NBF_SKEW_SECONDS,
    exp = now + ASSERTION_LIFETIME_SECONDS,
  }

  return require('kulala.cmd.crypto').jwt_encode(header, payload, table.concat(vim.fn.readfile(key_path), '\n'))
end

return M
