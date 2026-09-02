locals {
  strategic_ami_owner_accts = [
    "637257", # nyl-edutestimages-test
    "2111068", # nyl-edutestimages-dev
    "767397", # nyl-edutestimages-qa
    "76739054", # nyl-edutestimages-stage
    "47111297", # nyl-edutestimages-prod
    "52900686", # nyl-imagebuilder-test
    "6652633576", # nyl-imagebuilder-dev
    "2111254591", # nyl-imagebuilder-qa
    "85172536", # nyl-imagebuilder-stage
    "058264168", # nyl-imagebuilder-prod
  ]

  selected_ami = (
    var.instance.ami != null &&
    trimspace(var.instance.ami) != ""
    ) ? var.instance.ami : (
    var.instance.use_strategic_ami
    ? data.aws_ami.strategic[0].id
    : data.aws_ami.account[0].id
  )
}
