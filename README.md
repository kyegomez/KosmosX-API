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


# OPENAI AI MODEL API ARCHITECTURE

OpenAI likely has a complex infrastructure to support the scale and variety of their models. They probably use a combination of technologies, including Docker and Kubernetes, to manage their services. Each model could be wrapped in a FastAPI (or similar) application and deployed as a separate service. This would allow each model to scale independently based on demand.

The OpenAI Python SDK doesn't need to know the specifics of each model's deployment. Instead, it interacts with a unified API provided by OpenAI. This API likely routes requests to the appropriate model based on the model parameter in the API request. The routing could be done through an API gateway or a service mesh, which are common components in microservices architectures.

Here's a simplified example of how the process might work:

The user makes a request to the OpenAI API using the Python SDK. The request includes the model parameter, which specifies the model to use (e.g., "gpt-3.5-turbo").

The OpenAI API receives the request and routes it to the appropriate model service based on the model parameter.

The model service processes the request and returns the response.

The OpenAI API forwards the response back to the Python SDK.

The Python SDK returns the response to the user.

This is a simplified view and the actual process is likely more complex. For example, there might be additional layers for load balancing, caching, error handling, etc. Also, the model services might not directly process the requests, but instead put them in a queue for asynchronous processing.

In terms of how the models and the SDK "talk" to each other, they communicate over HTTP using a RESTful API. The Python SDK sends HTTP requests to the OpenAI API, and the API returns HTTP responses. The requests and responses are formatted as JSON, which is a common data format for RESTful APIs.

Again, this is speculative and based on common practices. The actual details of OpenAI's infrastructure are not publicly available.




In an AWS context, the infrastructure for deploying and managing AI models could be set up using a combination of various AWS services along with Terraform for infrastructure provisioning and Jenkins for CI/CD. Here's a simplified view of how it might work:

AWS ECR (Elastic Container Registry): This is where your Docker images would be stored. Each time you update your AI model and the corresponding Docker image, you would push the updated image to ECR.

AWS EKS (Elastic Kubernetes Service): This is the managed Kubernetes service where your AI models (wrapped in Docker containers) would be deployed. Each model could be deployed as a separate service within the EKS cluster.

AWS Route 53 or ALB (Application Load Balancer): This could serve as the entry point for all API requests. It could route incoming requests to the appropriate service in the EKS cluster based on the model parameter in the API request.

AWS RDS or DynamoDB: This could be used to store metadata about each model, such as its name, version, and the endpoint of the service in the EKS cluster.

Terraform: This would be used to provision and manage all the AWS resources. The Terraform scripts would define the desired state of your infrastructure, and Terraform would ensure that the actual state matches the desired state.

Jenkins: This would be used for CI/CD. Whenever you update your AI model, Jenkins would build a new Docker image, push it to ECR, and update the corresponding service in the EKS cluster to use the new image.

In terms of how the OpenAI Python SDK fits into this, you would need to develop a similar SDK for your API. This SDK would provide a simple interface for users to interact with your API. It would handle things like making HTTP requests to the API, authenticating with the API, and parsing the API responses.

When a user makes a request using the SDK, the request would be sent to the API endpoint (managed by Route 53 or ALB), which would route the request to the appropriate service in the EKS cluster based on the model parameter. The service would process the request and return the response, which would be forwarded back to the user by the SDK.

This is a high-level overview and the actual implementation could be more complex, depending on your specific requirements. Also, remember to handle sensitive data like API keys or passwords securely, for example by using AWS Secrets Manager or storing them securely in environment variables.

Now integrate all of 

AthenaThanks for becoming an alpha build user, email kye@apac.ai with all complaints