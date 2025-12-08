"""
Lambda function handler for the example-lambda3-non-prod function.
"""

import json
import logging
import os

# Configure logging
logger = logging.getLogger()
logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


def handler(event, context):
    """
    Main Lambda handler function.

    Args:
        event: The event data passed to the Lambda function.
               This could be from API Gateway, S3, SNS, CloudWatch Events, etc.
        context: The Lambda runtime context object containing metadata
                 about the invocation, function, and execution environment.

    Returns:
        dict: A response object with statusCode and body for API Gateway,
              or any JSON-serializable object for other triggers.
    """
    logger.info("Received event: %s", json.dumps(event))

    # Extract request details if coming from API Gateway
    http_method = event.get("httpMethod", "N/A")
    path = event.get("path", "/")
    query_params = event.get("queryStringParameters") or {}
    body = event.get("body")

    # Parse body if it's JSON
    if body:
        try:
            body = json.loads(body)
        except json.JSONDecodeError:
            pass  # Keep body as-is if not valid JSON

    # Log context information
    logger.info(
        "Function: %s, Request ID: %s, Remaining time: %dms",
        context.function_name,
        context.aws_request_id,
        context.get_remaining_time_in_millis(),
    )

    # Build response
    response_body = {
        "message": "Hello from example-lambda3-non-prod!",
        "function_name": context.function_name,
        "request_id": context.aws_request_id,
        "environment": "non-prod",
        "event": event,
    }

    # Return API Gateway compatible response
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "X-Request-Id": context.aws_request_id,
        },
        "body": json.dumps(response_body),
    }

