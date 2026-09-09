output "queue_name" {
  value = aws_sqs_queue.this.name
}

output "queue_url" {
  value = aws_sqs_queue.this.url
}

output "queue_arn" {
  value = aws_sqs_queue.this.arn
}

output "dead_letter_queue_name" {
  value = try(aws_sqs_queue.dlq[0].name, null)
}

output "dead_letter_queue_url" {
  value = try(aws_sqs_queue.dlq[0].url, null)
}

output "dead_letter_queue_arn" {
  value = try(aws_sqs_queue.dlq[0].arn, null)
}
