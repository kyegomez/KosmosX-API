# KosmosX-API
API for Deploying Kosmos-X

# Model Pricing

| MODEL FAMILY | DESCRIPTION | CONTEXT WINDOW | PAY-AS-YOU-GO PRICING | DEDICATED CAPACITY AVAILABLE |
| --- | --- | --- | --- | --- |
| Kosmos-X | The pinnacle of APAC AI's technology. A cutting-edge model designed for both advanced text generation (up to 20,000 tokens) and image analysis with object detection capabilities. This offering stands at the forefront of multimodal AI applications. | 20,000 tokens / Image | Yes | Yes |

## Details

### Kosmos-X Text API

Advanced text generation and understanding up to a context window of 20,000 tokens.

- Pay-As-You-Go: $0.20 per 1,000 tokens
- Dedicated Capacity: $150,000 per month for up to 50 million tokens

### Kosmos-X Image API

Advanced image analysis with object detection capabilities.

- Pay-As-You-Go: $0.50 per image processed
- Dedicated Capacity: $200,000 per month for up to 1 million images processed

Note: A token in APAC AI's usage refers to roughly 4 bytes of text. For instance, a character in English typically equates to one token. Images are priced per image processed, with additional charges for object detection capabilities.

Remember, regardless of the request size, you are charged a minimum of 100 tokens or 1 image per request.

## Pay-As-You-Go Pricing

With pay-as-you-go pricing, you pay only for what you use. There are no upfront costs or minimum fees. The pricing for the Kosmos-X model is premium, reflecting its superior capabilities and advanced features.

## Dedicated Capacity

For customers with high-volume, steady-state usage, we recommend considering our Dedicated Capacity plans. With dedicated capacity, you reserve inference capacity for your models in return for a significant discount on the on-demand price.

Email `kye@apac.ai` for dedicated capacity.


# To do:

* Integrate model wrapper and conversational logic

* Integrate supabase api key tracking

* Add token counters for text and images

* Integrate stripe usage payment tracking based on text and images

* Create Docker Compose

* Create KuberNetes

* Create Terraform config

* Create unit tests

* Create monitoring tests and dashboard



# Kubernets
`kubectl apply -f kosmosx-api-deployment.yaml`




# Jenkins

Integrating Jenkins into this setup would involve setting up a Continuous Integration/Continuous Deployment (CI/CD) pipeline. Jenkins would be responsible for building the Docker image for the AI model, pushing it to a Docker registry, and updating the Kubernetes Deployment to use the new image.

Here's a high-level overview of the architecture:

Code Repository: This is where your AI model's code is stored. It could be a Git repository on GitHub, GitLab, Bitbucket, etc.

Jenkins Server: Jenkins watches the code repository for changes. When a change is detected (e.g., when a commit is pushed), Jenkins triggers a new build.

Docker: Jenkins builds a Docker image for the AI model using a Dockerfile in the code repository.

Docker Registry: The Docker image is pushed to a Docker registry (e.g., Docker Hub, AWS ECR, GCR, etc.).

Kubernetes Cluster: The Kubernetes Deployment is updated to use the new Docker image. The Deployment automatically rolls out the update across the cluster.

AWS EKS: The Kubernetes cluster is managed by AWS EKS.

Here's an example of how you might define a Jenkins pipeline for this process:

pipeline {
    agent any

    stages {
        stage('Build Docker image') {
            steps {
                sh 'docker build -t my-ai-model:latest .'
            }
        }

        stage('Push Docker image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerHubCredentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'docker login -u $DOCKER_USER -p $DOCKER_PASS'
                    sh 'docker tag my-ai-model:latest $DOCKER_USER/my-ai-model:latest'
                    sh 'docker push $DOCKER_USER/my-ai-model:latest'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh 'kubectl set image deployment/ai-model-deployment ai-model=$DOCKER_USER/my-ai-model:latest --kubeconfig=$KUBECONFIG'
                }
            }
        }
    }
}

This Jenkinsfile defines a pipeline with three stages:

Build Docker image: This stage builds the Docker image for the AI model using the Dockerfile in the current directory.

Push Docker image: This stage pushes the Docker image to a Docker registry. It uses a Jenkins credential called 'dockerHubCredentials' to authenticate with the Docker registry.

Deploy to Kubernetes: This stage updates the Kubernetes Deployment to use the new Docker image. It uses a Jenkins credential called 'kubeconfig' to authenticate with the Kubernetes cluster.

You would need to replace 'dockerHubCredentials' and 'kubeconfig' with your actual Jenkins credential IDs, and 'my-ai-model' with your actual Docker image name.

