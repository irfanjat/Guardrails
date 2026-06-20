package main

required_tags := {"CostCenter", "Environment", "Owner"}

skip_resource_types := {
    "aws_iam_role",
    "aws_iam_policy",
    "aws_iam_role_policy_attachment",
    "aws_kms_key",
    "aws_kms_alias",
    "data.aws_iam_policy_document",
}

deny[msg] {
    change := input.resource_changes[_]
    not skip_resource_types[change.type]
    object.get(change.change.after, "tags", null) != null
    missing := required_tags[_]
    not change.change.after.tags[missing]

    msg := sprintf(
        "%s: Missing required tag %q on a taggable resource - without this tag, cost allocation, environment identification, and owner accountability are impossible",
        [change.address, missing],
    )
}

warn[msg] {
    change := input.resource_changes[_]
    not skip_resource_types[change.type]
    object.get(change.change.after, "tags", null) == null

    msg := sprintf(
        "%s: No tags block defined at all - add tags including CostCenter, Environment, and Owner for cost tracking and operations",
        [change.address],
    )
}
