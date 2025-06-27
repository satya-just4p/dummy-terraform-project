$terraformDir = "D:\Satyapriya\Projects\Testing\DummyTerraFormProject\TerraFormTemplate"
$baseApiUrl = terraform -chdir="$terraformDir" output -raw angular_base_api_url

$cloudFrontUrl = terraform -chdir="$terraformDir" output -raw angular_cloudfront_domain_name
Write-Output "Base Api Url is : $baseApiUrl"

# Variables
$bucketname = terraform -chdir="$terraformDir" output -raw s3_bucket_name
Write-Output "The bucketname is : $bucketname"

$region = terraform -chdir="$terraformDir" output -raw project_region
Write-Output "The region is : $region"


$distPath = "..\dist\dummy-ui\browser"

# Dist folder delete if already exists
if(Test-Path "..\dist")
{
    Remove-Item "..\dist" -Recurse -Force
    Write-Output "dist folder deleted"
}

$envFile = "..\src\environments\environment.prod.ts"
(Get-Content $envFile) -replace "REPLACE_ME_BASE_API_URL", $baseApiUrl | Set-Content $envFile
Write-Output "Base Api Url in environment.prod.ts replaced with : $baseApiUrl"

# Clear Angular Cache
npx ng Cache clear

# Angular Build
Write-Output "Building Angular App"
ng build --configuration production

# Deleting the exisiting items in S3 bucket if already uploaded
#Write-Output "Cleaning the S3 Bucket"
#aws s3 rm "s3://$bucketname" --recursive --region $region

Write-Output $distPath 

# Uploading the S3 objects to S3 bucket
aws s3 sync "$distPath" "s3://$bucketname" --region $region

# Upload successful
Write-Output "Upload Successful. Check the Url : $cloudFrontUrl"