---
publishDate: "2020-04-12"
title: "How to Create a Free VM Instance in GCP"
tags: ['GCP']
excerpt: "...as long as your usage stays within the free tier monthly allowance (750 hours per month for e2-micro instances), you will not be charged. "
image: /images/gcp-cloud.jpg
---

## Note on Billing Information

You might see an estimated charge on the billing page. However, as long as your usage stays within the free tier monthly allowance (750 hours per month for `e2-micro` instances), you will not be charged. This allowance applies across all instances, so you can run multiple instances, and the total hours used will count towards this monthly limit.

1. **Sign Up for GCP**

   - Visit the [Google Cloud Platform website](https://cloud.google.com) and sign up for a new account.
   - When you sign up, Google provides $300 in credits to use over the first 90 days.

2. **Access the Google Cloud Console**
   - Log in to the Google Cloud Console with your Google account.
3. **Enable the Compute Engine API**
   - Before creating a VM instance, ensure the Compute Engine API is enabled. Navigate to the **APIs & Services** section and enable the **Compute Engine API** if it's not already enabled.
4. **Navigate to the Compute Engine Section**
   - In the Cloud Console, go to the **Navigation menu** (three horizontal lines in the top left corner).
   - Select **Compute Engine** > **VM instances**.
5. **Create a New VM Instance**
   - Click the **Create Instance** button.
   - Fill out the instance details:
     - **Name**: Provide a name for your instance.
     - **Region and Zone**: Select a region and zone. For free tier eligibility, choose a region that supports the free tier, like `us-west1`, `us-central1`, or `us-east1`.
     - **Machine Configuration**: Choose the machine type. For free tier eligibility, select `e2-micro`, which is included in the free tier.
6. **Configure Boot Disk**
   - Under the **Boot disk** section, select the **Operating System** and version. The default is usually sufficient (Debian or Ubuntu).
7. **Firewall Settings**
   - Optionally, allow HTTP and HTTPS traffic by checking the respective boxes under the **Firewall** section.
8. **Create the Instance**
   - Review your settings and click the **Create** button to launch your VM instance.
9. **Access Your VM Instance**
   - Once the instance is created, you can access it by clicking the **SSH** button next to your instance name. This opens a browser-based terminal for managing your VM.
