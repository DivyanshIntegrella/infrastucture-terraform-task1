# infrastucture-terraform-task1
 This is to assign value of variable through command line.
 
 D:\task2> terraform apply -var="location=West Europe" -> this will set location to West Europe.
 
 D:\task2> terraform apply -var="rg_name=rg-divyansh-playground" -> this is use to select resource group.
 
 D:\task2> terraform apply -var="azure-terraform=App-Vnet" -> it is variable use to give name to virtual network.
 
 D:\task2> terraform apply -var="password=Divyansh@123, sensitive=true" -> it stores the password and sensitive is used so at the time of creating the password is hidden from the user.
 
 D:\task2> terraform apply -var="locals-name=gateway" -> A variable is created which has no pre-defined values.
 
 D:\task2> terraform apply -var='tenant="bd1024c1-001a-4eeb-963a-cfeccbc90226", sensitive=true' -> The tenant id is used for the key vault purpose and it should not be disclosed to user so sensitive is used.
 
 In this if any key is already assigned a value then it will override that values with these values.
