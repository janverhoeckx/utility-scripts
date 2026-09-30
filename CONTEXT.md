# Utility Scripts

Developer tools for obtaining OAuth tokens from Keycloak with a signed client assertion, and for inspecting AWS queues.

## Language

### OAuth

**Client Assertion**:
A short-lived JWT, signed with the client's private key, that authenticates the client to the token endpoint instead of a client secret.
_Avoid_: client JWT, signed JWT, client secret

**Audience**:
The `aud` of the Client Assertion — the token endpoint / realm the client authenticates against.
_Avoid_: aud (unqualified)

**Target Audience**:
The service the exchanged token is requested for in a Token Exchange; sent as the `audience` form parameter.
_Avoid_: audience (when meaning this)

**Subject Token**:
The existing access token that is handed over to be exchanged in a Token Exchange.
_Avoid_: input token, user token

**Grant**:
The kind of token request made: Client Credentials or Token Exchange.
_Avoid_: flow, mode

**Profile**:
A named, saved set of non-secret settings (client id, token url, Audience, Target Audience, algorithm) for one client in one environment. Never contains a private key or Subject Token.
_Avoid_: config, preset, environment
