#Variables

$angularDistPath = "D:\Satyapriya\Projects\Testing\DummyTerraFormProject\DummyUI\dist\dummy-ui\browser"
$s3BucketName = "bookstorewebappbucket.1981"
$awsRegion = "eu-central-1"

#Build Angular Project
ng build --configuration production

#upload Angular Build to S3

aws s3 sync $angularDistPath "s3://$s3BucketName" --region $awsRegion --delete --acl private

Write-Host "Upload Complete! Visit your CloudFront URL to test"