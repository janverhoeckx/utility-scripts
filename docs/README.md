# Browser tools

Self-contained HTML versions of the utility scripts, published with GitHub Pages from `main` `/docs` at https://janverhoeckx.github.io/utility-scripts/.

## OAuth Client Assertion (`oauth.html`)

Browser version of [client-credentials-grant](../client-credentials-grant) and [token-exchange](../token-exchange). It signs the client assertion with WebCrypto (RS256, RS384 or RS512) and sends the same form parameters as the scripts.

- The private key must be PKCS#8 (`-----BEGIN PRIVATE KEY-----`). Convert a PKCS#1 key with `openssl pkcs8 -topk8 -nocrypt -in key.pem -out key.p8.pem`.
- The private key and subject token are never stored. Profiles (client id, token url, audiences, scope, algorithm) are saved in the browser's `localStorage` and can be exported/imported as JSON.
- The page loads no external resources; its Content-Security-Policy only allows connections to `https:` URLs.

### CORS

The browser can only call a token endpoint that allows this page's origin. For Keycloak, add `https://janverhoeckx.github.io` to the client's **Web Origins**. Without it the request is blocked and the page shows a `curl` command instead. That command contains a freshly signed client assertion that expires after 60 seconds.
