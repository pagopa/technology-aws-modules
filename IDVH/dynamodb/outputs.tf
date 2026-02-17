output "table_name" {
  value = aws_dynamodb_table.this.name
}

output "table_id" {
  value = aws_dynamodb_table.this.id
}

output "table_arn" {
  value = aws_dynamodb_table.this.arn
}

output "stream_arn" {
  value = aws_dynamodb_table.this.stream_arn
}
