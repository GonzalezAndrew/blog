---
title: "DigitalOcean Terraform Remote State"
date: 2021-06-05T00:03:31-05:00
draft: false
author: "Andrew Gonzalez"
description: "Remote State for Terraform in DigialOcean"
comments: true
tags: 
  - terraform
  - digitalocean
  - tutorial
---


Recently I began to get interested in using [DigitalOcean](https://www.digitalocean.com/) has my personal playground. Granted DigitalOcean is not widely adopted but the small cloud provider has so much to offer at a resonable price compared to other providers such as AWS. Naturally, if I'm going to be deploying infrastructure, applications, etc to a cloud provider, I want to use Terraform. 

Terraform provides a simple but powerful way to invoke Cloud Provider APIs which allow you to provison infrastructure easily. Another great advantage of Terraform which I love, is the ability to know the state of the resources you deploy using Terraform. By knowing the state of your resources you have in your environment help leads away from configuration drift which other tools can suffer from when provisioning infrastructure such as Ansible. Another advantage of having the state with Terraform is the ability to use the state to inject data into other Terraform modules/scripts you might be working on. An example would be if you are deploying an EC2 instances to your AWS environment and you want to deploy said instance in a particular subnet that you deployed using Terraform. You could use Terraform remote state data block to import the subnet id the instance needs and would look something like so:

```hcl
data "terraform_remote_state" "vpc" {
  backend = "remote"

  config = {
    organization = "hashicorp"
    workspaces = {
      name = "vpc-prod"
    }
  }
}

resource "aws_instance" "foo" {
  subnet_id = data.terraform_remote_state.vpc.outputs.subnet_id
}
```

Thankfully, DigitalOcaen has a storage resouces called, [Spaces](https://www.digitalocean.com/products/spaces/), which work very similiarly to AWS S3 buckets. DigitalOcean developed the Spaces API to be able to work alongside the AWS S3 API, meaning you can use the `aws cil`, `aws s3api`, and other various tools which take advantage of the AWS S3 API to manipulate your DigitalOcean Spaces resources. This is fantastic! Since I already use AWS daily for work, moving to use DigitalOcean Spaces should be quite easy. This also means we can store all of our Terraform state files in a DigitalOcean Space and use the `terraform_remote_state` `s3` data block to pull any attributes from those saved statefiles. 

## Before Deploying the Space

If you want to follow along with this post, you'll first need a DigitalOcean account. Once you have created your DigitalOcean account, you'll need to create a DigialOcean API personal token and Space Access Keys. When creating your keys, try to choose a meaningful name for your keys so you know what or who might be using them. I used `terraform`, when creating my keys so next time I check the keys I know the purpose for the keys. Also, try to store your keys in a secure location which means please don't use a text file! If you're cheap like me, you could use [Bitwarden](https://bitwarden.com/) for you secrets vault. Bitwarden is super simple to use, can store all your SSH keys, logins, API Tokens, etc. Did I also mention it's free and open source ;)

## Deploying the Space

Once you have gathered all the necessary DigitalOcean credentials, we can now create the Space! Naturally, we are going to use Terraform to do this. You could use the beautiful DigitalOcean UI to create the Space but let's be honest, thats no fun. If you're lazy and don't want to go through the hazzle of writing 10 lines of HCL, you could use the [DigitalOcean Space Bucket Terraform Module](https://github.com/GonzalezAndrew/terraform-do-remote-state) I have already wrote! To use the module, follow the steps below.

1. Create a new directory named `terraform-do-remote-state`
```bash
$ mkdir -p ~/projects/terraform-do-remote-state
```
2. Create a `main.tf` file, import the module and fill out any attributes you want. For example:
```hcl
terraform {
  required_version = ">= 0.12.6, < 0.16"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}


provider "digitalocean" {
  token = "<do_token>"
  spaces_access_id = "<your_id>"
  spaces_secret_key = "<your_key>"
}

module "bucket" {
  source = "git::github.com/GonzalezAndrew/terraform-do-remote-state.git?ref=v1.0"
  name   = "tf-state-nyc3"
  region = "nyc3"
}
```
Yes, I have tried to set the DigitalOcean credentials using their appropriate environment variables but it doesnt work. So for now, I'm using static credentials and no I will not push this to GitHub and neither should you!

3. Run `terraform init`, `terraform plan`, and `terraform apply`
![Terminal](/images/posts/do_1.PNG)
4. Verify the Space was created correctly checking the DigitalOcean UI.
![UI](/images/posts/do_2.PNG)

That's it! You have now deployed a DigitalOcean Space that you can use for storing your Terraform remote state files. 
