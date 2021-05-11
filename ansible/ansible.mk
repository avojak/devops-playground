init:
	ansible-galaxy install -r requirements.yml

run:
	ansible-playbook play.yml --vault-password-file .vault-password-file