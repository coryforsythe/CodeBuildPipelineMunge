# CodeBuildPipelineMunge
This docker image can be used with AWS CodeBuild actions in AWS CodePipeline that require the use of multiple source archives.

As CodeBuild is limited to 5 inputs and 12 secondary artifacts, it can be difficult to express a pipeline with numerous sources.

This image allows CodeBuild to retrieve each source from the Pipeline that invoked the build (unzipping any archives in flight).

The source files are stored in a temporary directory and can then be re-packaged for downstream consumption in the pipeline.


## Usage

Create an AWS CodePipeline with multiple S3 Sources (in any stage)

Create a stage that has a CodeBuild activity

- Configure the CodeBuild project to use this container image

- Apply this buildspec to the build project:

- ```
  version: 0.2
  phases:
  build:
    commands:
      - /usr/local/bin/getSource
  artifacts:
  files:
     - /tmp/*/*
  discard-paths: yes
  ```

The buildspec will invoke a python script "getSource" that will download any S3 sources in the pipeline and extract them to a common directory under /tmp. This directory will then be packaged into an output artifact that can later be consumed

## IAM Considerations

The getSource script invoked from the container will leverage the AWS SDK to work with the S3 and CodePipeline services. As such, the CodeBuild Service Role will require permissions to perform these actions:

- codepipeline:getpipeline
- s3:getobject
  > s3:getObject can be restricted to the bucket prefixes of the source artifacts when known for a more granular control
