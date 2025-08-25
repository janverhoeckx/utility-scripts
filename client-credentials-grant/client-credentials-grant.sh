#!/bin/bash

# === Usage ===
if [ $# -lt 4 ]; then
  echo "Usage: $0 <client_id> <token_url> <private_key> <audience> [scope]"
  exit 1
fi

CLIENT_ID="$1"
TOKEN_URL="$2"
PRIVATE_KEY="$3"
AUDIENCE="$4"
SCOPE="$5"

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

# === Perform Client Credentials Grant ===
echo "Requesting access token using client credentials grant..."

# Build the curl request
CURL_DATA="grant_type=client_credentials"
CURL_DATA="${CURL_DATA}&client_id=$CLIENT_ID"
CURL_DATA="${CURL_DATA}&client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
CURL_DATA="${CURL_DATA}&client_assertion=$JWT"

# Add scope if provided
if [ -n "$SCOPE" ]; then
  CURL_DATA="${CURL_DATA}&scope=$SCOPE"
fi

curl -s -X POST "$TOKEN_URL" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "$CURL_DATA" | jq .
