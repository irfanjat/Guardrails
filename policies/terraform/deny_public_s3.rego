package main

deny[msg] {
    change := input.resource_changes[_]
    change.type == "aws_s3_bucket"
    change.change.after.acl == "public-read"

    msg := sprintf(
        "%s: S3 bucket %q has ACL set to public-read - anyone on the internet can read this bucket's objects, risking data exposure",
        [change.address, change.change.after.bucket],
    )
}

deny[msg] {
    change := input.resource_changes[_]
    change.type == "aws_s3_bucket"
    change.change.after.acl == "public-read-write"

    msg := sprintf(
        "%s: S3 bucket %q has ACL set to public-read-write - anyone on the internet can read and write objects, enabling data theft or ransomware",
        [change.address, change.change.after.bucket],
    )
}

deny[msg] {
    change := input.resource_changes[_]
    change.type == "aws_s3_bucket"
    attrs := change.change.after

    attrs.acl == "private"
    object.get(attrs, "block_public_acls", false) != true

    msg := sprintf(
        "%s: S3 bucket %q has ACL private but block_public_acls is not enabled - accidental ACL changes could expose data",
        [change.address, change.change.after.bucket],
    )
}
