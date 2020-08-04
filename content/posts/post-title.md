---
title: "Post Title"
date: 2020-08-03T20:59:00-06:00
draft: true
toc: false
images:
tags: 
  - untagged
---

testing
```hcl
terraform {
  backend "s3" {
    bucket         = "foo"
    key            = "path/to/my/key"
    region         = "eu-west-1"
    dynamodb_table = "bar"
  }
}
```

> after

```hcl
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "acme"

    workspaces {
      name = "foo"
    }
  }
}
```