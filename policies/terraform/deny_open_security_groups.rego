package main

sensitive_ports := {22, 3389, 3306, 5432, 6379, 27017}

port_names := {
    22: "SSH",
    3389: "RDP",
    3306: "MySQL",
    5432: "PostgreSQL",
    6379: "Redis",
    27017: "MongoDB",
}

deny[msg] {
    change := input.resource_changes[_]
    change.type == "aws_security_group"
    ingress := change.change.after.ingress[_]
    cidr := ingress.cidr_blocks[_]
    cidr == "0.0.0.0/0"
    port := ingress.from_port
    sensitive_ports[port]
    name := port_names[port]

    msg := sprintf(
        "%s: Security group opens port %v (%s) to 0.0.0.0/0 - allows anyone on the internet to access %s, enabling brute-force attacks and unauthorized access",
        [change.address, port, name, name],
    )
}

deny[msg] {
    change := input.resource_changes[_]
    change.type == "aws_security_group"
    ingress := change.change.after.ingress[_]
    cidr := ingress.cidr_blocks[_]
    cidr == "0.0.0.0/0"
    ingress.from_port == 0
    ingress.to_port == 65535

    msg := sprintf(
        "%s: Security group opens all ports (0-65535) to 0.0.0.0/0 - complete public exposure, any service on any port is reachable from the internet",
        [change.address],
    )
}
