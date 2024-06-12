---
title: GCP Services Overview
tags: [GCP, cheat-sheet]
header:
  overlay_image: /assets/images/google-services.jpg
  overlay_filter: 0.5 # same as adding an opacity of 0.5 to a black background
  teaser: /assets/images/google-services.jpg
excerpt: "A quick guide about the various services offered in the Google cloud."
---

## Cloud Shell

In GCP, find the Cloud Shell icon, which looks like a terminal, in the top right corner of the console toolbar. Clicking this opens a new terminal session in your browser. Cloud Shell provides a cli environment with tools like `gcloud` and `kubectl`, allowing you to manage your GCP resources without installing any software on your machine.

## GCP Project Organization

GCP organizes resources into projects, which are isolated environments with their own permissions and billing settings. This is different than AWS, where resources are organized into accounts, and a single AWS account can have multiple environments with services like AWS Organizations and AWS Resource Groups. Both platforms aim to provide clear resource management, GCP's project-centric approach offers an easy to understand hierarchy , especially beneficial for granular permission control and billing management within a single account. Plus, when you first sign up, Google gives you a $300 credit so you can experiment with GCP!

1. **Projects**: A project is a unique entity in GCP, it is identified by a project ID. Projects contain all your resources, and they provide boundaries for permissions and billing.

2. **Folders**: Folders help you group multiple projects. This is useful for large organizations that manage many projects across different departments or teams.

3. **Organizations**: At the top level, the organization node represents your company. This allows for centralized management of projects and folders.

4. **IAM (Identity and Access Management)**: IAM roles and permissions are assigned at the organization, folder, and project levels. This approach allows granular control over who or what can access and manage resources.

## GCP Compute Services

GCP offers a many compute services designed for different workloads and app requirements.

1. **Compute Engine** (EC2): This service provides VM that you can launch. You can choose from many predefined or custom machine types.

2. **Google Kubernetes Engine (GKE)** (EKS): GKE is a managed Kubernetes service that allows you to run containerized applications. It automates deployment, scaling, and operations of Kubernetes.

3. **App Engine** (Beanstalk): App Engine is a fully managed platform-as-a-service (PaaS) that lets you build and deploy applications quickly. It supports multiple languages and frameworks, and automatically handles the infrastructure, scaling, and monitoring.

4. **Cloud Functions**(lambda): A serverless compute service that lets you run code in response to events without using servers. It’s ideal for building lightweight, event-driven applications and microservices.

5. **Cloud Run**(Fargate): Cloud Run allows you to run stateless containers that are fully managed. It uses serverless computing and containers,wich makes it easy to deploy and scale applications.

## Brief Overview of GCP Storage Services

1. **Cloud Storage** (S3): A scalable, fully managed object storage service for storing unstructured data like images, videos, and backups. It supports multiple storage classes: Standard, Nearline, Coldline, and Archive.

2. **Persistent Disk** (EBS): Provides high-performance block storage for use with Compute Engine and Google Kubernetes Engine. There are two types: Standard (HDD) and SSD. They both can be resized and offer automatic encryption.

3. **Filestore**(EFS): A managed file storage service for applications that require a file system interface and shared file storage. Filestore is used for workloads like content management, media processing, and home directories.

4. **Cloud SQL**(RDS): A fully managed relational database service for MySQL, PostgreSQL, and SQL Server. Cloud SQL handles tasks such as backups, replication, and patch management.

5. **Cloud Spanner**: A globally distributed, horizontally scalable relational database service designed for mission-critical applications. Cloud Spanner offers strong consistency, high availability, and automatic scaling.

6. **Cloud Bigtable** (DynamoDB): A fully managed NoSQL database service. It’s optimized for high throughput and low latency. Ideal for time-series data, IoT data, and real-time analytics.

7. **Cloud Datastore**(DynamoDB): A NoSQL document database service designed for web and mobile applications. It offers scaling, high availability, and strong consistency with a query language.

8. **Cloud Firestore**: An evolution of Cloud Datastore, offering a NoSQL document database with real-time synchronization and offline capabilities. Good for mobile, web, and server applications.

## Overview of GCP Network Services

1. **VPC (Virtual Private Cloud)**: VPC allows you to define a virtual network within GCP, offering complete control over IP address ranges, subnets, routing, and firewalls. It provides isolated, secure environments for deploying resources.

2. **Cloud Load Balancing**: A fully distributed, software-defined managed service for distributing traffic across multiple instances or regions. It supports HTTP(S), TCP/SSL, and UDP load balancing, ensuring high availability and reliability for your applications.

3. **Cloud CDN (Content Delivery Network)**: Speeds up the delivery of web content by caching it at edge locations around the world. Cloud CDN integrates with Cloud Load Balancing to optimize performance and reduce latency for users globally.

4. **Cloud Interconnect**: Provides high-speed, dedicated connections between your on-premises network and Google’s network. This service includes Dedicated Interconnect and Partner Interconnect, offering different levels of connectivity based on your needs.

5. **Cloud VPN**: Establishes secure, encrypted tunnels between your on-premises network or another cloud provider and your GCP VPC network. This helps extend your private network securely into the cloud.

6. **Cloud DNS**: A scalable, reliable, and managed authoritative DNS service running on the same infrastructure as Google. It translates domain names into IP addresses, ensuring your services are easily accessible.

7. **Traffic Director**: A managed service mesh offering traffic management, security, and observability for microservices running on GCP. It helps you deploy resilient applications with advanced traffic control features.

8. **Network Service Tiers**: Offers Premium and Standard tiers to give you control over your network performance and cost. The Premium Tier leverages Google’s global network for the highest performance and reliability, while the Standard Tier offers a cost-effective regional network.

9. **Firewall Rules**: GCP provides customizable firewall rules to control traffic to and from your instances. These rules help secure your network by allowing or denying traffic based on specified criteria.

10. **Cloud NAT (Network Address Translation)**: Allows instances without public IP addresses to access the internet securely. It helps maintain security by keeping instances private while enabling outbound connectivity.
