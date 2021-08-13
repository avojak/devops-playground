GitLab: http://192.168.1.58:8080
Artifactory: http://192.168.1.59:8082/ui

Registering GitLab runner using Docker: https://docs.gitlab.com/runner/register/index.html#docker

SSH Access:

```bash
$ ssh -i id_rsa provisioner@192.168.1.58
```

Notes:
- May need to restart the server after running the IPv6 disable task for the first time
- Mail isn't configured for GitLab, to change passwords use: https://forum.gitlab.com/t/reset-user-password-as-admin-no-mail-reset/13027
- SSL is terminated by Apache, so SSL configuration is not necessary within Artifactory or GitLab

```bash
gitlab-rails runner -e production " \
  user = User.find_by(id: 1);
  user.password = user.password_confirmation = 'the_secret_word'; \
  user.save!"
```

TODO:
- Use Ansible vault to store the certs

GitLab Runners:
- https://docs.gitlab.com/runner/register/index.html#docker
- For the URL, use: https://gitlab.vojak.dev/
- docker executor
- ubuntu:latest as default image

For each GitLab Runner using Docker, register it using:

```bash
$ docker run --rm -it -v /srv/gitlab-runner-XX/config:/etc/gitlab-runner gitlab/gitlab-runner register
```

Logs:
- apache2 logs in /var/log/apache2

Secrets:

```bash
$ cd ansible
$ ansible-vault edit secrets.yml --vault-password-file=".vault-password-file"
```