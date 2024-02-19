param(
    [string]$RESOURCE_GROUP,
    [string]$CONTAINER_ENVIRONMENT,
    [string]$AZP_TOKEN,
    [string]$ORGANIZATION_URL,
    [string]$AZP_POOL
)

$PLACEHOLDER_JOB_NAME = "ado-agent-placeholder"
$JOB_NAME = "ado-agent"

Write-Host "----------------------------------------------------------------"
Write-Host "Creating a placeholder job in the container environment..."
# Create a new place holder job in the container environment - required
az containerapp job create -n "$PLACEHOLDER_JOB_NAME" -g "$RESOURCE_GROUP" --environment "$CONTAINER_ENVIRONMENT" `
    --trigger-type Manual `
    --replica-timeout 300 `
    --replica-retry-limit 0 `
    --replica-completion-count 1 `
    --parallelism 1 `
    --image "docker.io/zoltanchivai/ado-agnet:v1" `
    --cpu "2.0" `
    --memory "4Gi" `
    --secrets "personal-access-token=$AZP_TOKEN" "organization-url=$ORGANIZATION_URL" `
    --env-vars "AZP_TOKEN=secretref:personal-access-token" "AZP_URL=secretref:organization-url" "AZP_POOL=$AZP_POOL" "AZP_PLACEHOLDER=1" "AZP_AGENT_NAME=placeholder-agent" 

# Wait 10 sec
Start-Sleep -Seconds 10

Write-Host "----------------------------------------------------------------"
Write-Host "Place holder job starting..."
# Run the place holder job
az containerapp job start -n "$PLACEHOLDER_JOB_NAME" -g "$RESOURCE_GROUP"
az containerapp job start -n "ado-agent-placeholder" -g "rg-ado-serverless-agents"


Write-Host "----------------------------------------------------------------"
Write-Host "Creating a new job in the container environment..."

# Create a new job in the container environment
az containerapp job create -n "$JOB_NAME" -g "$RESOURCE_GROUP" --environment "$CONTAINER_ENVIRONMENT" `
    --trigger-type Event `
    --replica-timeout 1800 `
    --replica-retry-limit 0 `
    --replica-completion-count 1 `
    --parallelism 1 `
    --image "docker.io/zoltanchivai/ado-agnet:v1" `
    --min-executions 0 `
    --max-executions 10 `
    --polling-interval 30 `
    --scale-rule-name "azure-pipelines" `
    --scale-rule-type "azure-pipelines" `
    --scale-rule-metadata "poolName=$AZP_POOL" "targetPipelinesQueueLength=1" `
    --scale-rule-auth "personalAccessToken=personal-access-token" "organizationURL=organization-url" `
    --cpu "2.0" `
    --memory "4Gi" `
    --secrets "personal-access-token=$AZP_TOKEN" "organization-url=$ORGANIZATION_URL" `
    --env-vars "AZP_TOKEN=secretref:personal-access-token" "AZP_URL=secretref:organization-url" "AZP_POOL=$AZP_POOL" 
