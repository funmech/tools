# Run containers in AWS

There are a few ways to run containers on AWS. On GCP, managed service like Cloud Run and GKE are the most common ways to run containers. Cloud Run is dead simple and can set up run with other service simply. Even with GKE, there is not too much to worry. With Cloud Build, CI/CD pipelines can be setup quickly.

AWS has been in the history book very long, so you can see articles to explain how to run containers with EC2. Of course containers can be run from ESC and EKS as you can imagine. But that just part of the story. They are Orchestration tools. So there are choices of runtime: AWS Fargate and of course EC2. So to fully understand it does not like running: `gcloud --help`, you have to really spend time to read lots of documents, blogs and ultimately Google. The definitions of assets of course are in Cloud Formation but that has very deep and wide scopes. AWS does not believe it is for normal person working on their cloud, so there are multiple tools to translate configurations to Cloud Formation stacks.

## Run a web service in containers using managed services

### 1. EKS with Fargate
 1. Tools: eksctl (0.90.0) and kubectl (1.21)
 2. Steps:
    ```bash
    eksctl create cluster --name super --region ap-southeast-2 --fargate --with-oidc
    eksctl delete cluster --name super --region ap-southeast-2

    # EKS on Fargate needs a profile. On Fargate, containers are run from private subnets, eksctl magically only select private subnets, not like on Console you have to do a manual selection.
    eksctl create fargateprofile \
        --cluster my_super_cluster \
        --name fargate_profile_super \
        --namespace super

    # We need to used a load balancer, so we have to define a policy, which can be kept and reused.
    aws iam create-policy \
        --policy-name AWSLoadBalancerControllerIAMPolicy \
        --policy-document file://aws_alb_iam_policy.json
    # Need to take note of its ARN, which will be used in the next step. The number after iam is your account string. So most likely you can

    # Need to create a service account for the iam policy in the cluster.
    eksctl create iamserviceaccount \
    --cluster=super \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --role-name "AmazonEKSLoadBalancerControllerRole" \
    --attach-policy-arn=arn:aws:iam::11111111111:policy/AWSLoadBalancerControllerIAMPolicy \
    --approve

    # By this time, there are not much left for eksctl, except when you need to run it for deletion.

    ## aws load balancer should be installed as an add-on. There are two ways (no surprise), but using helm was only the successful way in my investigation.
    ## I run these in aws cloud shell, so you may have different dependence issues.
    sudo yum install openssl
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
    chmod 700 get_helm.sh
    ./get_helm.sh

    helm repo add eks https://aws.github.io/eks-charts
    helm repo update

    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=super \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    --set image.repository=602401143452.dkr.ecr.ap-southeast-2.amazonaws.com/amazon/aws-load-balancer-controller \
    --set region=ap-southeast-2 \
    --set vpcId=vpc-0d43deb6598ef0144


    # check it with kubectl, it will take a bit of time to be ready:
    kubectl get deployment -n kube-system aws-load-balancer-controller

    NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
    aws-load-balancer-controller   2/2     2            2           2m

    # Once aws-load-balancer-controller is installed successfully, it is time to deploy kubenets Deployment, Service and Ingress. Then you will have a public accessible web service.
    kubectl apply -f aws_eks_super_full.yaml

    # if you like, what you have done, send it to oblivion:
    eksctl delete cluster --name camunda --region ap-southeast-2
    ```

    * [aws_alb_iam_policy.json](aws_alb_iam_policy.json)
    * Some [extra steps](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html) of [super service](aws_eks_super_full.yaml)
    * Anything missing, does not work, check [official documents](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html). Good luck!

## Fargate

   * [Official documents](https://docs.aws.amazon.com/AmazonECS/latest/userguide/getting-started-fargate.html)