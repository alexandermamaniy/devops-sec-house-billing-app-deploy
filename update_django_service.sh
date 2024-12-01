ssh -i ~/.ssh/mtckey ubuntu@10.0.1.168 "cd devops-sec-house-billing-app-deploy/django-service-deploy && \
					docker compose -f docker-compose.staging.yml down && \
					docker pull x23329823/house_billing_web_service && \
					docker compose -f docker-compose.staging.yml up -d --force-recreate"
