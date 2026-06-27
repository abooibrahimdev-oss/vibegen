#!/bin/bash
M=$(tr -d '[:space:]' < /root/bedrock/model.txt 2>/dev/null)
case "$M" in
  anthropic.claude-3-sonnet-20240229-v1:0|\
  anthropic.claude-3-haiku-20240307-v1:0|\
  amazon.titan-text-express-v1|\
  meta.llama3-70b-instruct-v1:0|\
  cohere.command-text-v14)
    exit 0 ;;
esac
echo "Not quite. Run 'aws bedrock list-foundation-models', copy one exact modelId, and save it: echo \"<modelId>\" > /root/bedrock/model.txt"
exit 1
