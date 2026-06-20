package main

deny[msg] {
    change := input.resource_changes[_]
    change.type == "aws_s3_bucket"
    object.get(change.change.after, "server_side_encryption_configuration", null) == null

    msg := sprintf(
        "%s: S3 bucket does not have server-side encryption enabled - data at rest could be read if the physical disks are compromised",
        [change.address],
    )
}

deny[msg] {
    change := input.resource_changes[_]
    change.type == "aws_db_instance"
    change.change.after.storage_encrypted == false

    msg := sprintf(
        "%s: RDS instance does not have storage encryption enabled - database data at rest could be read from the underlying storage",
        [change.address],
    )
}

deny[msg] {
    change := input.resource_changes[_]
    change.type == "aws_ebs_volume"
    change.change.after.encrypted == false

    msg := sprintf(
        "%s: EBS volume does not have encryption enabled - disk data at rest is readable if the volume snapshot or physical disk is accessed",
        [change.address],
    )
}

deny[msg] {
    change := input.resource_changes[_]
    change.type == "aws_dynamodb_table"
    val := object.get(change.change.after, "server_side_encryption", [])
    val[0].enabled == false

    msg := sprintf(
        "%s: DynamoDB table does not have server-side encryption enabled - table data at rest could be exposed",
        [change.address],
    )
}
