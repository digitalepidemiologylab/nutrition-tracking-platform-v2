# AICrowd Food API

## Schemas

### Sequence diagram for the interaction between MyFoodRepo and AICrowd Food API

```mermaid
sequenceDiagram
  participant mfr_app as MFR App
  participant mfr_worker as MFR Worker
  participant mfr_cron as MFR Cron
  participant aicrowd_app as AICrowd App
  participant aicrowd_worker as AICrowd Worker
  mfr_app -) mfr_worker : Create job
  activate mfr_worker
  mfr_worker ->> aicrowd_app : POST /enqueue
  activate aicrowd_app
  aicrowd_app -) aicrowd_worker : Create job
  activate aicrowd_worker
  aicrowd_app --) mfr_worker : POST /enqueue response
  deactivate aicrowd_app
  deactivate mfr_worker
  par aicrowd_worker to mfr_app
    aicrowd_worker --) mfr_app : POST webhook url
  and mfr_cron to aicrowd_app
    loop Every 1 day at 3am
      Note over mfr_cron,aicrowd_app : Rake task `segmentations:get_stale_pending_status`
      activate aicrowd_app
      mfr_cron ->> aicrowd_app : GET /status/:job_id
      aicrowd_app --) mfr_cron : GET /status/:job_id response
      deactivate aicrowd_app
    end
  end
  deactivate aicrowd_worker
```

### AICrowd Food API architecture

```mermaid
flowchart LR
  A[Request] --> B["Load Balancer (:443)"]
  subgraph AWS["AWS (vpc-9b41a7f2)"]
    B --> C["Docker"]
    subgraph EC2["Server (EC2 Instance :8000)"]
      C
    end
  end
```

## Server

### Info

The server is an EC2 instance on AWS.

* Instance type: `g4dn.xlarge`
* Instance zone: `eu-central` (Frankfurt)
* Instance name: `AICrowd Food API`
* AWS VPC: `vpc-9b41a7f2`
* Elastic IP linked to the instance: `18.158.148.138`
* Public DNS: `ec2-18-158-148-138.eu-central-1.compute.amazonaws.com`
* The API server runs on the port `8000`
* Open ports:
  * 22: For SSH connections, accessible worldwide
  * 8000: For the app, accessible only by the `sg-86c627ef` security group (the group used by the load balancer)

### How to connect

You can find the ssh key on 1Password under the name `AICrowd Food API EC2 SSH Key`.

Then, run the following command: `ssh -i ~/.ssh/aicrowd_food_api_key.pem ubuntu@18.158.148.138`

## Load balancer

* AWS Name: `aicrowd-food-api-load-balancer`
* AWS Target group: `aicrowd-food-api-target-group`
* AWS VPC: `vpc-9b41a7f2`
* DNS name: `aicrowd-food-api-lb-636477160.eu-central-1.elb.amazonaws.com`
* DNS CNAME: `aicrowd-api.myfoodrepo.org` – DNS server for myfoodrepo.org is on [NameCheap](www.namecheap.com)
* Open port: 443 (HTTPS/SSL)
* The SSL certificate is created and managed by the AWS Certificate Manager

### Resources

* https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html

## Code repository

The main code repository for the AICrowd Food API is hosted on a [gitlab.aicrowd.com](https://gitlab.aicrowd.com/food-recognition-challenge/food-recognition-api-v1).

We also have a backup of this repository on our [GitHub account](https://github.com/digitalepidemiologylab/aicrowd-food-api).

## ML models backup

On the main [repository](#code-repository), [Git LFS](https://git-lfs.github.com) is used to store the ML models. Due to GitHub limit to max 4Go files, we can't do the same on our GitHub repository backup. So we use S3 to backup ML models:

* Bucket: `myfoodrepo-backup`
* Folder: `aicrowd-ml-models`
* Storage class: `Glacier Flexible Retrieval` (formerly Glacier)
