#!/usr/bin/env bash
set -eu

for i in "$@"; do
  terraform fmt -diff "$i"
done
