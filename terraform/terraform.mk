init:
	terraform init
plan:
	terraform plan
apply:
	terraform apply
destroy:
	terraform destroy

.PHONY: lint
lint:
	terraform validate