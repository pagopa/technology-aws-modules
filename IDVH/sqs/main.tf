module "idvh_loader" {
  source = "../01_idvh_loader"

  product_name       = var.product_name
  env                = var.env
  idvh_resource_tier = var.idvh_resource_tier
  idvh_resource_type = "sqs"
}

locals {
  fifo_queue = local.idvh_config.fifo_queue

  normalized_name = lower(replace(var.name, "_", "-"))

  queue_name = local.fifo_queue ? (
    endswith(local.normalized_name, ".fifo") ?
    local.normalized_name :
    "${local.normalized_name}.fifo"
  ) : trimsuffix(local.normalized_name, ".fifo")

  dlq_suffix = local.idvh_config.dead_letter_queue.name_suffix

  dlq_name_base = "${local.queue_name}-${local.dlq_suffix}"
  dlq_name = local.fifo_queue ? (
    endswith(local.dlq_name_base, ".fifo") ?
    local.dlq_name_base :
    "${local.dlq_name_base}.fifo"
  ) : trimsuffix(local.dlq_name_base, ".fifo")

  create_dead_letter_queue = local.idvh_config.dead_letter_queue.enabled

  effective_visibility_timeout_seconds = var.visibility_timeout_seconds != null ? var.visibility_timeout_seconds : local.idvh_config.visibility_timeout_seconds

  effective_sqs_managed_sse_enabled = var.kms_key_id == null ? local.idvh_config.sqs_managed_sse_enabled : false
}

resource "aws_sqs_queue" "dlq" {
  count = local.create_dead_letter_queue ? 1 : 0

  name                        = local.dlq_name
  fifo_queue                  = local.fifo_queue
  content_based_deduplication = local.fifo_queue ? local.idvh_config.content_based_deduplication : null

  delay_seconds                     = local.idvh_config.delay_seconds
  max_message_size                  = local.idvh_config.max_message_size
  message_retention_seconds         = local.idvh_config.message_retention_seconds
  receive_wait_time_seconds         = local.idvh_config.receive_wait_time_seconds
  visibility_timeout_seconds        = local.effective_visibility_timeout_seconds
  sqs_managed_sse_enabled           = local.effective_sqs_managed_sse_enabled
  kms_master_key_id                 = var.kms_key_id
  kms_data_key_reuse_period_seconds = local.idvh_config.kms_data_key_reuse_period_seconds

  tags = merge(
    var.tags,
    {
      Name = local.dlq_name
    }
  )
}

resource "aws_sqs_queue" "this" {
  name                        = local.queue_name
  fifo_queue                  = local.fifo_queue
  content_based_deduplication = local.fifo_queue ? local.idvh_config.content_based_deduplication : null

  delay_seconds                     = local.idvh_config.delay_seconds
  max_message_size                  = local.idvh_config.max_message_size
  message_retention_seconds         = local.idvh_config.message_retention_seconds
  receive_wait_time_seconds         = local.idvh_config.receive_wait_time_seconds
  visibility_timeout_seconds        = local.effective_visibility_timeout_seconds
  sqs_managed_sse_enabled           = local.effective_sqs_managed_sse_enabled
  kms_master_key_id                 = var.kms_key_id
  kms_data_key_reuse_period_seconds = local.idvh_config.kms_data_key_reuse_period_seconds

  redrive_policy = local.create_dead_letter_queue ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = local.idvh_config.dead_letter_queue.max_receive_count
  }) : null

  tags = merge(
    var.tags,
    {
      Name = local.queue_name
    }
  )
}
