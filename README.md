# DCI OpenStack agent test lab

## Requirements

You need docker up and running. It should also be able to access the insecure registries on Docker bridge.

As root:

    dnf install -y docker
    echo 'INSECURE_REGISTRY=\'--insecure-registry 172.0.0.0/8' >> /etc/sysconfig/docker-latest
    systemctl enable docker
    systemctl start docker


## Usage

    ./start.sh OSP9

If you want to overwrite the content of the last rpm with your own git repositories in `$HOME/git_repos`:

    env DEV=1 ./start.sh OSP9
