# SQS Poller
This script polls a given AWS SQS queue and writes all received messages to a JSON file. Messages are processed in batches and automatically deleted from the queue after being saved.

## Example usage

```bash
./sqs-poller.sh <queue-url> <output-file> [max-messages] [wait-time-seconds] [poll-count]
```

- queue-url: The URL of the SQS queue to poll
- output-file: Path to the output JSON file where messages will be stored
- max-messages: Maximum number of messages to receive per request (default: 10, max: 10)
- wait-time-seconds: Long polling wait time in seconds (default: 20, max: 20)
- poll-count: Number of times to poll the queue (default: 1)

## Example scenarios

**Single poll with defaults:**
```bash
./sqs-poller.sh https://sqs.eu-west-1.amazonaws.com/123456789/my-queue messages.json
```

**Poll 5 times with custom parameters:**
```bash
./sqs-poller.sh https://sqs.eu-west-1.amazonaws.com/123456789/my-queue messages.json 10 20 5
```

**Continuous polling (1000 iterations = ~5.5 hours with 20s wait time):**
```bash
./sqs-poller.sh https://sqs.eu-west-1.amazonaws.com/123456789/my-queue messages.json 10 20 1000
```

## Notes

- The script saves messages in JSON format, preserving the original message structure
- Message bodies are automatically parsed as JSON if possible, otherwise stored as strings
- Each message includes metadata: messageId, receiptHandle, body, and receivedAt timestamp
- Messages are automatically deleted from the queue after being saved
- The script requires AWS CLI to be installed and configured with appropriate credentials
- The script requires `jq` for JSON processing
- Long polling (wait-time-seconds) reduces the number of API calls and costs
- Output file is formatted as a JSON array for easy processing

## Output format

The output JSON file is an array of message objects:

```json
[
  {
    "messageId": "12345678-1234-1234-1234-123456789012",
    "receiptHandle": "AQEBuX...",
    "body": { "key": "value" },
    "receivedAt": "2025-01-12T14:30:00Z"
  },
  {
    "messageId": "87654321-4321-4321-4321-210987654321",
    "receiptHandle": "AQEBqX...",
    "body": "Plain text message",
    "receivedAt": "2025-01-12T14:30:02Z"
  }
]
```

## Requirements

- AWS CLI installed and configured
- `jq` for JSON processing
- AWS credentials with permissions to receive and delete messages from the target SQS queue

