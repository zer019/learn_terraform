# learn_terraform
The goal of this repo is to rapidly learn Terraform.

Goals:
    Build a Linux instance
    Install a webserver (apache/tomcat/whatever) web server
    Create a basic HTML webpage which displays custom text and is accessible publicly
    Comment in terraform code explaining what each portion does

TODO:
    See about using S3 sync to create/replace the index.html file as proof of concept
    Automate DNS record creation
    Automate Let's encrypt cert acquisition (Relies on DNS A record)
    Look into route resources and associate to table instead of inline routes
    Don't need to use depends_on as much, see where this can be removed to simplify
    Move instance type to main as Var
    Life-cycle param to prevent ec2 destroy on AMI changes, if you don't want it to destroy and rebuild on ami changes