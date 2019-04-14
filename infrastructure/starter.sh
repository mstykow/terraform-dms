#!/usr/bin/env bash

terraform fmt

terraform plan

echo "yes" | terraform apply