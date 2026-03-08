"""
Bedrock Agent Action Group Lambda Handler

This Lambda function processes action group invocations from Amazon Bedrock Agents.
It receives structured requests with the API path and parameters, executes the
corresponding business logic, and returns responses in the expected format.
"""

import json
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handler(event, context):
    """
    Main handler for Bedrock Agent action group invocations.

    Args:
        event: The event payload from Bedrock Agent containing:
            - actionGroup: Name of the action group
            - apiPath: The API path being invoked
            - httpMethod: The HTTP method (GET, POST, etc.)
            - parameters: List of parameter objects
            - requestBody: The request body content
            - messageVersion: Message format version
        context: Lambda context object

    Returns:
        dict: Response object with statusCode and body for the agent
    """
    logger.info("Received event: %s", json.dumps(event, default=str))

    action_group = event.get("actionGroup", "")
    api_path = event.get("apiPath", "")
    http_method = event.get("httpMethod", "GET")
    parameters = event.get("parameters", [])
    request_body = event.get("requestBody", {})
    message_version = event.get("messageVersion", "1.0")

    # Extract parameters into a dictionary for easier access
    params = {}
    if parameters:
        for param in parameters:
            params[param.get("name")] = param.get("value")

    logger.info(
        "Processing action_group=%s, api_path=%s, method=%s",
        action_group,
        api_path,
        http_method,
    )

    try:
        # Route to the appropriate handler based on API path
        response_body = route_request(api_path, http_method, params, request_body)
        status_code = 200
    except ValueError as e:
        logger.warning("Validation error: %s", str(e))
        response_body = {"error": str(e)}
        status_code = 400
    except NotImplementedError:
        logger.warning("Unimplemented API path: %s", api_path)
        response_body = {"error": f"API path {api_path} is not implemented"}
        status_code = 404
    except Exception as e:
        logger.error("Unexpected error: %s", str(e), exc_info=True)
        response_body = {"error": "An internal error occurred"}
        status_code = 500

    # Format response for Bedrock Agent
    action_response = {
        "actionGroup": action_group,
        "apiPath": api_path,
        "httpMethod": http_method,
        "httpStatusCode": status_code,
        "responseBody": {
            "application/json": {
                "body": json.dumps(response_body, default=str)
            }
        },
    }

    api_response = {
        "messageVersion": message_version,
        "response": action_response,
    }

    logger.info("Returning response: %s", json.dumps(api_response, default=str))
    return api_response


def route_request(api_path, http_method, params, request_body):
    """
    Route the incoming request to the appropriate handler function.

    Implement your business logic here by adding cases for each API path
    defined in your action group's OpenAPI schema.

    Args:
        api_path: The API path string
        http_method: The HTTP method
        params: Dictionary of extracted parameters
        request_body: The request body content

    Returns:
        dict: Response body to return to the agent
    """
    # Example routing - replace with your actual API paths
    if api_path == "/lookup" and http_method == "GET":
        query = params.get("query", "")
        return perform_lookup(query)
    elif api_path == "/submit" and http_method == "POST":
        return process_submission(request_body)
    else:
        raise NotImplementedError(f"No handler for {http_method} {api_path}")


def perform_lookup(query):
    """
    Example lookup function. Replace with your actual implementation.

    Args:
        query: The search query string

    Returns:
        dict: Lookup results
    """
    return {
        "results": [],
        "query": query,
        "message": "Implement your lookup logic here",
    }


def process_submission(request_body):
    """
    Example submission processor. Replace with your actual implementation.

    Args:
        request_body: The submitted data

    Returns:
        dict: Processing result
    """
    return {
        "status": "received",
        "message": "Implement your submission processing logic here",
    }
