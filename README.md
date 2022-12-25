```
██╗  ██╗ ██████╗ ██╗  ████████╗███████╗███╗   ███╗ █████╗ ███╗   ██╗
██║  ██║██╔═══██╗██║  ╚══██╔══╝╚══███╔╝████╗ ████║██╔══██╗████╗  ██║
███████║██║   ██║██║     ██║     ███╔╝ ██╔████╔██║███████║██╔██╗ ██║
██╔══██║██║   ██║██║     ██║    ███╔╝  ██║╚██╔╝██║██╔══██║██║╚██╗██║
██║  ██║╚██████╔╝███████╗██║   ███████╗██║ ╚═╝ ██║██║  ██║██║ ╚████║
╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝   ╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝

        ███████╗███████╗███████╗███████╗ ██████╗████████╗
        ██╔════╝██╔════╝██╔════╝██╔════╝██╔════╝╚══██╔══╝
        █████╗  █████╗  █████╗  █████╗  ██║        ██║
        ██╔══╝  ██╔══╝  ██╔══╝  ██╔══╝  ██║        ██║
        ███████╗██║     ██║     ███████╗╚██████╗   ██║
        ╚══════╝╚═╝     ╚═╝     ╚══════╝ ╚═════╝   ╚═╝
```

[![CI](https://github.com/repconn/holtzman-effect/actions/workflows/ci.yml/badge.svg)](https://github.com/repconn/holtzman-effect/actions/workflows/ci.yml)


# Abstract

> Do you have an AWS account and want your own VPN server,
> but you don't like infrastructure?

*Holtzman Effect* help you to *Run your own private VPN server on AWS from scratch*

* Built from scratch, no predefined images
* Completely private
* Secure enough

## What is inside

Holtzman Effect is a collection of open source tools such as Terraform, Terragrunt,
Ansible, Docker and OpenVPN that are glued together by a Makefile and are always
ready to provide you a full-fledged, enterprise grade VPN server.

## Requirements
* [Docker](https://docs.docker.com/get-docker/) installed on your machine
* [Valid AWS Account](https://aws.amazon.com/console/) and [AWS Access keys](https://docs.aws.amazon.com/powershell/latest/userguide/pstools-appendix-sign-up.html)

## Quick Start

* `make config`
* `make install`