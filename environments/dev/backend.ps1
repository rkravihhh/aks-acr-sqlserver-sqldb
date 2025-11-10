$RESOURCE_GROUP = "ravi1"
$STORAGE_ACCOUNT = "devopravi111125"   # must be globally unique, lowercase
$CONTAINER_NAME = "tfstate"
$LOCATION = "eastus"

az group create -n $RESOURCE_GROUP -l $LOCATION
az storage account create -n $STORAGE_ACCOUNT -g $RESOURCE_GROUP -l $LOCATION --sku Standard_LRS
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT --auth-mode login
