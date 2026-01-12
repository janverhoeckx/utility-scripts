#!/bin/bash

# === Usage ===
if [ $# -lt 2 ]; then
  echo "Usage: $0 <queue-url> <output-file> [max-messages] [wait-time-seconds] [poll-count]"
  exit 1
fi

QUEUE_URL="$1"
OUTPUT_FILE="$2"
MAX_MESSAGES="${3:-10}"
WAIT_TIME="${4:-20}"
POLL_COUNT="${5:-1}"

# === Validation ===
if [ ! -d "$(dirname "$OUTPUT_FILE")" ]; then
  echo "Error: Output directory does not exist: $(dirname "$OUTPUT_FILE")"
  exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
  echo "Error: AWS CLI is not installed. Please install it first."
  exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  echo "Error: jq is not installed. Please install it first."
  exit 1
fi

# === Initialize output file ===
echo "[]" > "$OUTPUT_FILE"

# === Poll SQS Queue ===
echo "Starting to poll SQS queue: $QUEUE_URL"
echo "Max messages per request: $MAX_MESSAGES"
echo "Wait time: $WAIT_TIME seconds"
echo "Poll count: $POLL_COUNT"
echo

TOTAL_MESSAGES=0
POLL_ITERATION=0

while [ $POLL_ITERATION -lt $POLL_COUNT ]; do
  POLL_ITERATION=$((POLL_ITERATION + 1))

  echo "[$(date +'%Y-%m-%d %H:%M:%S')] Poll iteration $POLL_ITERATION of $POLL_COUNT..."

  # Receive messages from SQS
  RESPONSE=$(aws sqs receive-message \
    --queue-url "$QUEUE_URL" \
    --max-number-of-messages "$MAX_MESSAGES" \
    --wait-time-seconds "$WAIT_TIME" \
    2>&1)

  # Check if the command was successful
  if [ $? -ne 0 ]; then
    echo "Error: Failed to receive messages from SQS queue"
    echo "$RESPONSE"
    exit 1
  fi

  # Extract messages from response
  MESSAGES=$(echo "$RESPONSE" | jq '.Messages // []')
  MESSAGE_COUNT=$(echo "$MESSAGES" | jq 'length')

  if [ "$MESSAGE_COUNT" -eq 0 ]; then
    echo "No messages received in this poll"
    if [ $POLL_ITERATION -lt $POLL_COUNT ]; then
      echo "Waiting $WAIT_TIME seconds before next poll..."
    fi
    continue
  fi

  echo "Received $MESSAGE_COUNT message(s)"

  # Process and store each message
  for i in $(seq 0 $((MESSAGE_COUNT - 1))); do
    MESSAGE=$(echo "$MESSAGES" | jq ".[$i]")
    RECEIPT_HANDLE=$(echo "$MESSAGE" | jq -r '.ReceiptHandle')
    MESSAGE_BODY=$(echo "$MESSAGE" | jq -r '.Body')
    MESSAGE_ID=$(echo "$MESSAGE" | jq -r '.MessageId')

    # Try to parse body as JSON, otherwise keep as string
    if echo "$MESSAGE_BODY" | jq . &> /dev/null; then
      PARSED_BODY=$(echo "$MESSAGE_BODY" | jq .)
    else
      PARSED_BODY=$(echo "\"$MESSAGE_BODY\"")
    fi

    # Create message object with metadata
    MESSAGE_OBJECT=$(cat <<EOF
{
  "messageId": "$MESSAGE_ID",
  "receiptHandle": "$RECEIPT_HANDLE",
  "body": $PARSED_BODY,
  "receivedAt": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
}
EOF
)

    # Append message to output file
    TEMP_FILE=$(mktemp)
    jq ". += [$(echo "$MESSAGE_OBJECT" | jq -c .)]" "$OUTPUT_FILE" > "$TEMP_FILE"
    mv "$TEMP_FILE" "$OUTPUT_FILE"

    TOTAL_MESSAGES=$((TOTAL_MESSAGES + 1))

    # Delete message from queue
    echo "  Deleting message $MESSAGE_ID from queue..."
    aws sqs delete-message \
      --queue-url "$QUEUE_URL" \
      --receipt-handle "$RECEIPT_HANDLE" > /dev/null

    if [ $? -eq 0 ]; then
      echo "  Message $MESSAGE_ID deleted successfully"
    else
      echo "  Warning: Failed to delete message $MESSAGE_ID"
    fi
  done

  if [ $POLL_ITERATION -lt $POLL_COUNT ]; then
    echo "Waiting $WAIT_TIME seconds before next poll..."
  fi
done

echo
echo "=== Polling Complete ==="
echo "Total messages polled and saved: $TOTAL_MESSAGES"
echo "Output file: $OUTPUT_FILE"
echo
echo "Messages saved in JSON format:"
jq . "$OUTPUT_FILE" | head -50
if [ $TOTAL_MESSAGES -gt 50 ]; then
  echo "... (showing first 50 lines)"
fi

