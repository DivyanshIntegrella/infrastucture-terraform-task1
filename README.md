# infrastucture-terraform-task1
By using environment variable

Terraform searches the environment of its own process for environment variables named TF_VAR_ followed by the name of a declared variable.

In linux and mac os export keyword is used before environment variables TF_VAR_ .
example : export TF_VAR_location="westeurope".

In windows export keyword will give error instead of export we use SET-ITEM -path env:TF_VAR_<variable name> -value <value>.
example : SET-ITEM -path env:TF_VAR_location -value "westeurope".
