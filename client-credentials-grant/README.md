# Client Credentials Grant
With this script an access token can be requested at an OAuth Identity Provider using the Client Credentials Grant flow. The script uses Client Assertion for authentication.

## Example usage

```bash
./client-credentials-grant.sh <client-id> <token-url> <private-key> <audience> [scope]
```

- client id: The client id which is requesting the token
- token url: URL to the token endpoint of the Identity Provider
- private key: Path to private key file in PEM format
- audience: Audience for the client assertion JWT
- scope: Optional scope parameter for the access token request

## Notes

- The script generates a JWT for client assertion using RS256 algorithm
- The private key should be in PEM format
- The script requires `jq` for JSON formatting of the response
- The script requires `uuidgen` for generating unique JWT IDs
