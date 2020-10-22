---
title: "Legos Docker Container"
date: 2020-10-21
draft: false
toc: true
author: "Andrew Gonzalez"
tags: 
  - docker
  - terraform
  - ansible
  - automation
---

![Docker Image](/static/post-images/docker.jpg)

# Introduction
Lately due to current circumstances, I have been slowly getting adjusted to working from home. The main challenges I have found from adjusting to my new work environment, was having to constantly transition my development between my work machine, personal macbook air, windows gaming pc, and my linux box. Having the proper binaries or packages I use between each machine become a chore, I constantly ran into version issues with Terraform or just did not have a particular binary installed. 

# Brainstorm
I came up with a small list of possible solutions that I could possible use to help myself avoid running into some of the issues I explained above. 

## Custom CLI
The first idea I had was to create a cli wrapper using go, which would 'wrap' all other binaries and allow me to invoke a specific tool when given the appropriate argument. The main reason for this idea was to give myself an excuse to finally learn go and to experiment with the various Hashicorp tools that are natively written using go. I decided not to pursue this idea due to the large number of packages I used daily that are written using other various programming languages such as Ansible or Molecule.

## Ansible Roles
The second idea I drafted up was the use of [Ansible roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html) to provision my machines. This idea would have been great for it would allow me to better stretch my understanding of Ansible across different distrubtions. Along with using Ansible to download packages, I could use Ansible to provision features such as dotfiles or download applications across all my machines. Unfortunately, I decided to move on from this idea due to the fact that I wanted a quick solution that I could write up in hours. I do plan on revisiting this idea over the upcoming winter season for this solution will give me greater reach in customization.

## Docker Container
I ended up landing on the idea of using Docker to help solve my problems. Using Docker allows me to easily share the container on any machine that has Docker installed. Additionally, I could use a simple bash script to further abstract the docker commands and arguments to help aid the speed of executing each individual binary that would be installed on the Docker container.

# The Legos Container
I wanted to design the Legos container to be my swiss army knife that I could carry with me in any distribution or machine. I also wanted Legos to be sharable to anyone in any environment. 

At the core, Legos has a small number of packages installed but I do plan on adding addditional packages and features to help enrich the containers usabillity. Currently the packages that are avaliable on Legos are as follows:
- [terraform](https://www.terraform.io/): Used for provisioning cloud resources on a almost every cloud provider.
- [aws-cli](https://aws.amazon.com/cli/): Used for interacting with the AWS API directly.
- [packer](https://www.packer.io/): Used to build machine or docker images.
- [vault](https://www.vaultproject.io/): Used as a secrets management tool.
- [ansible](https://www.ansible.com/): Used to automate cloud resources, application development, intra-service orchestration and much more.

# Expanding Legos Further
As I explained above, I wanted to expand the Legos container further with the aid of bash. I wanted to have the ability to call the container quickly and not have to manually type in a larger `docker run` command. I came up with the bash function below that helped me get over this hurtle and can be placed in your `~/.bashrc` or wherever you store your additional sourced bash functions.

```bash
legos(){
    local key=${1}
    case $1 in
        "ansible")
        bin=$1
        shift
        ;;
        "terraform")
        bin=$1
        shift
        ;;
        "vault")
        bin=$1
        shift
        ;;
        "packer")
        bin=$1
        shift
        ;;
        "aws")
        bin=$1
        shift
        ;;
        *)
        echo "Unrecognized option: $key"
        exit 1
    esac

    docker run --rm \
        -w /tmp \
        -v $(pwd):/tmp/ \
        -v ~/.aws/:/root/aws \
        -v ~/.ssh:/root/.ssh \
        andrewgonzo/legos:latest "$bin" "$@"
}
```

As you can see, the function `legos` allows me to easily call a binary that is installed in the Legos container without having to type in the long `docker run` command that follows the case statement. I decided to add both the `~/.ssh` and `~/.aws` directory to allow myself to use my credentials when I need them. Of course, you can change this function to fit your needs such as adding additonal arguments.

If you are interested in Legos, please visit my [GitHub repoistory](https://github.com/GonzalezAndrew/docker-apps/tree/master/legos) where I store all my Docker containers. If you have suggestions on how I could to make Legos better, I would love to hear them or please contribute to the repository.