```

██╗   ██╗ █████╗  ██████╗██╗   ██╗███╗   ███╗
╚██╗ ██╔╝██╔══██╗██╔════╝██║   ██║████╗ ████║
 ╚████╔╝ ███████║██║     ██║   ██║██╔████╔██║
  ╚██╔╝  ██╔══██║██║     ╚██╗ ██╔╝██║╚██╔╝██║
   ██║   ██║  ██║╚██████╗ ╚████╔╝ ██║ ╚═╝ ██║
   ╚═╝   ╚═╝  ╚═╝ ╚═════╝  ╚═══╝  ╚═╝     ╚═╝

```

[![CI](https://github.com/repconn/yacvm/actions/workflows/ci.yml/badge.svg)](https://github.com/repconn/yacvm/actions/workflows/ci.yml)


# Abstract

**YACVM** stands for **Y**et **A**nother **C**LI **V**PN **M**anager

> Do you have an AWS account and want your own VPN server,
> but you don't like infrastructure?

*YACVM* help you to *Run your own private VPN server on AWS from scratch*

* Built from scratch, no predefined images
* Completely private
* Secure enough

## What is inside

YACVM is a collection of open source tools such as Terraform, Terragrunt,
Ansible, Docker and OpenVPN that are glued together by a Makefile and are always
ready to provide you a full-fledged, enterprise grade VPN server.

## Requirements
* [Docker](https://docs.docker.com/get-docker/) installed on your machine
* [Valid AWS Account](https://aws.amazon.com/console/) and [AWS Access keys](https://docs.aws.amazon.com/powershell/latest/userguide/pstools-appendix-sign-up.html)

## Quick Start

* `make config`
* `make install`
* `make vpnconfig elonmusk`

## FAQ

> My external IP address is changed and I can't connect to the server via SSH.
In this case the "make ping" command also will fail. Perform "make deploy"
command to add your current IP address to AWS security group.
