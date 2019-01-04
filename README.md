# CodeBuildPipelineMunge
This docker image can be used with AWS CodeBuild actions in AWS CodePipeline that require the use of multiple source archives.

As CodeBuild is limited to 5 inputs and 12 secondary artifacts, it can be difficult to express a pipeline with numerous sources.

This image allows CodeBuild to retrieve each source from the Pipeline that invoked the build (unzipping any archives in flight).

The source files are stored in a temporary directory and can then be re-packaged (by the pipeline) for downstream consumption.

## Usage

Create an AWS CodePipeline with multiple S3 Sources (in any stage)

Create a downstream stage that has a CodeBuild activity

- Configure the related CodeBuild project to use this [container image](https://cloud.docker.com/u/corygforsythe/repository/docker/corygforsythe/codebuildpipelinemunge)

- Apply the following buildspec to the build project:

 ```
  version: 0.2
  phases:
  build:
    commands:
      - /usr/local/bin/getSource
  artifacts:
  files:
     - '**/*'
  discard-paths: no
  ```

The buildspec will invoke a python script "getSource" that will download any S3 sources in the pipeline and extract them

### (optional) Specify a set of artifacts

If you do not wish to consume all available sources from the pipeline you may optionally set the *Artifacts_Included* and *Artifacts_Excluded* environment variables.  These variables may contain a comma-separated list of artifact names (those used in the pipeline) to include in the munged version.  Setting *Artifacts_Included* will override any values set in *Artifacts_Excluded*.  To do so, adjust the buildspec accordingly:

```
version: 0.2
phases:
build:
  commands:
    - /usr/local/bin/getSource
artifacts:
files:
   - '**/*'
discard-paths: no
env:
 variables:
  Artifacts_Included: someArtifactName
```
## IAM Considerations

The getSource script invoked from the container will leverage the AWS SDK to work with the S3 and CodePipeline services. As such, the CodeBuild Service Role will require permissions to perform these actions (in addition to other required actions):

- codepipeline:getpipeline
- s3:getobject
  > s3:getObject can be restricted to the bucket prefixes of the source artifacts when known for a more granular control

> For a complete list of other IAM actions necessary, review the [corresponding AWS documentation](https://docs.aws.amazon.com/codebuild/latest/userguide/auth-and-access-control-iam-identity-based-access-control.html)
