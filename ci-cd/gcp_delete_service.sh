
PROJECT_ID="gcp-web-example"
REGION="asia-southeast1"

# 1. Cloud Run Service
gcloud run services delete user-catalog-service \
  --region=$REGION \
  --project=$PROJECT_ID \
  --quiet

# 2. Cloud SQL
gcloud sql instances delete coin-id-pg \
  --project=$PROJECT_ID \
  --quiet

# 3. Pub/Sub Subscription
gcloud pubsub subscriptions delete coin-image-uploaded-sub \
  --project=$PROJECT_ID \
  --quiet

# 4. Pub/Sub Topic
gcloud pubsub topics delete coin-image-uploaded \
  --project=$PROJECT_ID \
  --quiet

# 5. Artifact Registry Repository
gcloud artifacts repositories delete coin-id-repo \
  --location=$REGION \
  --project=$PROJECT_ID \
  --quiet

# 6. Cloud Storage Bucket
gcloud storage rm -r gs://coin-images --quiet

# 7. Global Static IP
gcloud compute addresses delete coin-id-lb-ip \
  --global \
  --project=$PROJECT_ID \
  --quiet

terraform apply -auto-approve


gcloud run services list --region=asia-southeast1 --project=gcp-web-example

gcloud sql instances list --project=gcp-web-example

gcloud pubsub subscriptions list --project=gcp-web-example

gcloud pubsub topics list --project=gcp-web-example


