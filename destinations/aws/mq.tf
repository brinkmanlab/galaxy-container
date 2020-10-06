resource "aws_sqs_queue" "message_queue" {
  name_prefix = local.instance
  fifo_queue = false
}

resource "aws_sqs_queue_policy" "test" {
  queue_url = aws_sqs_queue.message_queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.message_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.example.arn}"
        }
      }
    }
  ]
}
POLICY
}