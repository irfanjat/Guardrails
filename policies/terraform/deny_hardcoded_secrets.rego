package main

sensitive_attributes := {
    "password",
    "secret_key",
    "secret_access_key",
    "api_key",
    "private_key",
    "access_key",
    "db_password",
    "master_password",
}

deny[msg] {
    change := input.resource_changes[_]
    attr := sensitive_attributes[_]
    val := change.change.after[attr]
    val != "***"
    val != ""
    val != null

    msg := sprintf(
        "%s: Attribute %q contains a value that appears to be a plaintext secret (not marked as sensitive in Terraform) - use a secret store like AWS Secrets Manager or a CI/CD variable instead of hardcoding credentials",
        [change.address, attr],
    )
}

deny[msg] {
    change := input.resource_changes[_]
    tags := change.change.after.tags
    count(tags) > 0
    tag_name := [k | v := tags[k]][_]
    val := tags[tag_name]

    contains(lower(val), "password")
    val != "***"

    msg := sprintf(
        "%s: Tag %q has a value that looks like a secret (%q) - tags are visible to anyone with read access and are often logged, do not put secrets in tags",
        [change.address, tag_name, val],
    )
}
