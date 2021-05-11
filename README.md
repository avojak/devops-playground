GitLab: http://192.168.1.58:8080
Artifactory: http://192.168.1.59:8082/ui

Registering GitLab runner using Docker: https://docs.gitlab.com/runner/register/index.html#docker

Notes:
- May need to restart the server after running the IPv6 disable task for the first time
- Mail isn't configured for GitLab, to change passwords use: https://forum.gitlab.com/t/reset-user-password-as-admin-no-mail-reset/13027
- SSL is terminated by Apache, so SSL configuration is not necessary within Artifactory or GitLab

TODO:
- Use Ansible vault to store the certs

GitLab Runners:
- https://docs.gitlab.com/runner/register/index.html#docker
- For the URL, use the local IP address: http://192.168.1.58:8080
- docker executor