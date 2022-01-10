# Dev(Sec)Ops Playground

This is a minimal end-to-end setup for standing up some tools within my [homelab](https://www.reddit.com/r/homelab/wiki/introduction).

The infrastructure- and configuration-as-code in this repository will:

1. Generate SSH keys
2. Leverage Packer to create an Ubuntu 18.04 server OVA with the above SSH keys baked in for a `provisioner` account
3. Leverage Terraform to deploy the VM image to an existing ESXi host
4. Leverage Ansible (and the `provisioner` account) to deploy various tools to the new VM

## Prerequisites

1. An ESXi host
2. (Optional) A reverse proxy to terminate SSL and route connections to the appropriate server
3. (Optional) DDNS service/container running to keep DNS records up-to-date with changing home IP address

## Running

There is a top-level `Makefile` with some rules to wrap commands that I don't want to have to remember.

The first step is to `make init` to generate the SSH keys, and run various other initialization tasks for Terraform and Ansible.

It's a good idea to verify all config files with a quick `make lint` before proceeding any further.

### 1. Packer

Next, we can create the OVA image:

```bash
$ make image
```

The resulting image will be: `packer/output/ubuntu-18.04-server/packer-ubuntu-18.04.ova`

### 2. Terraform

To provision our VM on the ESXi host:

```bash
$ make plan-deploy # Optional
$ make deploy
```

You will need to ensure that the ESXi host has the SSH service enabled temporarily - *don't forget to disable this when you're done!*

If something goes wrong, you can undeploy the VM with:

```bash
$ make undeploy
```

### 3. Ansible

Now we can install the software to the newly-created VM:

```bash
$ make install
```

If you need to make changes to the `secrets.yml` file:

```bash
$ cd ansible
$ ansible-vault edit secrets.yml --vault-password-file=".vault-password-file"
```

#### Troubleshooting

- Within the network, you can use the SSH keys generated at the start to login as the provisioner:

  ```bash
  $ ssh -i id_rsa provisioner@<vm-ip-address>
  ```

- You may need to restart the server after running the IPv6 disable task for the first time

#### GitLab

You may need to run `gitlab-ctl reconfigure` to kick GitLab into picking up configuration changes, or to troubleshoot issues.

#### GitLab HTTPS

Note that HTTPS is disabled for GitLab. This setup assumes a reverse proxy on the edge of the network which handles SSL termination, so
HTTPS, HTTP->HTTPS redirection, LetsEncrypt, etc. are all disabled in the GitLab installation.

#### GitLab Runners

For the GitLab runners there's a bit of a chicken-and-egg scenario where we need to provide a registration token to the runners, but that's not
available to us until GitLab is already setup. As a result, you can comment-out the `gitlab-runner` role in the playbook for the first run, and then
once you've obtained the token from the admin page, update the value in the `secrets.yml` file.

If you need to manually register runners:

```bash
$ docker run --rm -it -v /srv/gitlab-runner-XX/config:/etc/gitlab-runner gitlab/gitlab-runner register
```

Runner Configuration:
- See: https://docs.gitlab.com/runner/register/index.html#docker
- For the URL, use: https://gitlab.vojak.dev/
- Use the Docker executor
- Use `ubuntu:latest` as default image

#### GitLab Registration

No SSH, SMTP, etc. is allowed into the network, so user registration must be done manually. After creating a new user from the admin page, you
will need to [manually set their password](https://forum.gitlab.com/t/reset-user-password-as-admin-no-mail-reset/13027):

```bash
gitlab-rails runner -e production " \
  user = User.find_by(id: 1);
  user.password = user.password_confirmation = 'the_secret_word'; \
  user.save!"
```

#### GitLab Cloning and Pushing

Because no SSH connections are allowed into the network from the outside, all git operations must be performed via the HTTPS URLs, not via SSH.

## Traefik

The `traefik` directory contains a copy of the configuration used to run a Traefik container as a reverse proxy.

## DDNS

For DDNS, I'm using the `oznu/cloudflare-ddns` container:

```yaml
version: '2'
services:
  cloudflare-ddns:
    image: oznu/cloudflare-ddns:latest
    restart: always
    environment:
      - API_KEY=XXXXXXXXXX
      - ZONE=vojak.dev
      - SUBDOMAIN=home
      - PROXIED=true
```