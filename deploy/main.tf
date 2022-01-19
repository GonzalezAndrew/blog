
module "hugo_blog" {
  source  = "GonzalezAndrew/app-site/digitalocean"
  version = "0.0.1"
  spec = [{
    name   = "blog"
    region = "nyc1"

    domain = {
      name = "blog.gonzalezandrew.com"
      type = "PRIMARY"
      zone = "gonzalezandrew.com"
    }

    static_site = {
      name             = "blog"
      build_command    = "hugo -d public"
      environment_slug = "hugo"
      source_dir       = "/"

      github = {
        repo           = "GonzalezAndrew/blog"
        branch         = "master"
        deploy_on_push = true
      }

      routes = {
        path = "/"
      }
    }
  }]
}

resource "digitalocean_project" "this" {
    name = "blog"
    description = "A project to reprsent all resources for my blog."
    purpose = "Blog"
    environment = "Production"
    resources = [module.hugo_blog.id]
}
