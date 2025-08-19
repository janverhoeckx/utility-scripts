#!/bin/bash

# === Usage ===
if [ $# -lt 4 ]; then
  echo "Usage: $0 <subject_token> <client_id> <token_url> <private_key> [audience]"
  exit 1
fi

SUBJECT_TOKEN="$1"
CLIENT_ID="$2"
TOKEN_URL="$3"
PRIVATE_KEY="$4"
AUDIENCE="$5"   
TARGET_AUDIENCE="$6" 

# === Create client_assertion JWT ===
HEADER='{"alg":"RS256","typ":"JWT"}'

PAYLOAD=$(cat <<EOF
{
  "iss": "$CLIENT_ID",
  "sub": "$CLIENT_ID",
  "aud": "$AUDIENCE",
  "jti": "$(uuidgen)",
  "exp": $(($(date +%s)+300))
}
EOF
)

# Base64URL encode helper
b64url_encode() {
  echo -n "$1" | openssl base64 -e -A | tr '+/' '-_' | tr -d '='
}

HEADER_B64=$(b64url_encode "$HEADER")
PAYLOAD_B64=$(b64url_encode "$PAYLOAD")
SIGN_INPUT="${HEADER_B64}.${PAYLOAD_B64}"

# Sign with private key
SIGNATURE=$(echo -n "$SIGN_INPUT" | \
  openssl dgst -sha256 -sign "$PRIVATE_KEY" | \
  openssl base64 -e -A | tr '+/' '-_' | tr -d '=')

JWT="${SIGN_INPUT}.${SIGNATURE}"

echo "Generated client_assertion JWT:"
echo "$JWT"
echo

# === Perform Token Exchange ===
echo "Exchanging subject_token for a new token..."
curl -s -X POST "$TOKEN_URL" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=urn:ietf:params:oauth:grant-type:token-exchange" \
  -d "subject_token=$SUBJECT_TOKEN" \
  -d "audience=$TARGET_AUDIENCE" \
  -d "client_id=$CLIENT_ID" \
  -d "requested_token_type=urn:ietf:params:oauth:token-type:access_token"\
  -d "client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer" \
  -d "client_assertion=$JWT" | jq .
