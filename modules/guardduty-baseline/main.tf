resource "aws_guardduty_detector" "default" {
  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency

  # datasources can't be individually managed in each member account.
  dynamic "datasources" {
    for_each = var.master_account_id == "" ? [var.master_account_id] : []

    content {
      s3_logs {
        enable = true
      }
    }
  }

  tags = var.tags
}

resource "aws_guardduty_member" "members" {
  count = length(var.member_accounts)

  detector_id                = aws_guardduty_detector.default.id
  invite                     = true
  account_id                 = var.member_accounts[count.index].account_id
  disable_email_notification = var.disable_email_notification
  email                      = var.member_accounts[count.index].email
  invitation_message         = var.invitation_message
}

resource "aws_guardduty_invite_accepter" "master" {
  count = var.master_account_id != "" ? 1 : 0

  detector_id       = aws_guardduty_detector.default.id
  master_account_id = var.master_account_id
}

resource "aws_cloudwatch_event_rule" "guard_duty" {
  name        = "guard-duty-events"
  description = "Capture each AWS GuardDuty events"

  event_pattern = <<EOF
{
  "source": [
    "aws.guardduty"
  ],
  "detail-type": [
    "GuardDuty Finding"
  ],
  "detail": {
    "severity": [
      4,
      4.0,
      4.1,
      4.2,
      4.3,
      4.4,
      4.5,
      4.6,
      4.7,
      4.8,
      4.9,
      5,
      5.0,
      5.1,
      5.2,
      5.3,
      5.4,
      5.5,
      5.6,
      5.7,
      5.8,
      5.9,
      6,
      6.0,
      6.1,
      6.2,
      6.3,
      6.4,
      6.5,
      6.6,
      6.7,
      6.8,
      6.9,
      7,
      7.0,
      7.1,
      7.2,
      7.3,
      7.4,
      7.5,
      7.6,
      7.7,
      7.8,
      7.9,
      8,
      8.0,
      8.1,
      8.2,
      8.3,
      8.4,
      8.5,
      8.6,
      8.7,
      8.8,
      8.9
    ]
  }
}
EOF
}
