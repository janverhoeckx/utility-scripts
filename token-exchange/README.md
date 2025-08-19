# Token Exchange
With this script an access token can be requested at an OAuth Identity Provider with the Token Exchange flow. The script uses Client Assertion.

## Example usage

```bash
./token-exchange/token-exchange.sh <access-token> <client-id> <token url> <private key> <target audience> 
```

- access token: The token to exchange
- client id: The client id which is performing the exchange
- token url: URL to the token endpoint of the Identity Provider
- private key: Path to private key file in PEM format
- target audience: Audience which will receive the token