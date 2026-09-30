# Token Exchange
With this script an access token can be requested at an OAuth Identity Provider with the Token Exchange flow. The script uses Client Assertion.

## Example usage

```bash
./token-exchange.sh <access-token> <client-id> <token url> <private key> <audience> <target audience> [algorithm]
```

- access token: The token to exchange
- client id: The client id which is performing the exchange
- token url: URL to the token endpoint of the Identity Provider
- private key: Path to private key file in PEM format
- audience: Audience for the Client Assertion. Typically this is the Identity Provider
- target audience: Audience which will receive the token
- algorithm: Optional signature algorithm for the client assertion JWT: RS256 (default), RS384 or RS512

A browser version of this tool is hosted at https://janverhoeckx.github.io/utility-scripts/oauth.html (see [docs/README.md](../docs/README.md)).
