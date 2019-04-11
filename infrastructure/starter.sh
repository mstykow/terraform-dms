#!/usr/bin/env bash

terraform fmt

terraform plan -var-file="starter_vars.tfvars"

echo "yes" | terraform apply -var-file="starter_vars.tfvars"