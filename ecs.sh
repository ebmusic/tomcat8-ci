#!/bin/bash
set -vx
TASK_REVISION_RAW=$(aws ecs register-task-definition \
    --region ${AWS_REGION} \
    --family app \
    --network-mode awsvpc \
    --memory ${MEMORY} \
    --cpu ${CPU} \
    --requires-compatibilities FARGATE \
    --execution-role-arn "${EXECUTION_ROLE_RAW}"/"${ECS_SERVICE_ROLE}" \
    --container-definitions "[{\"memory\":${MEMORY},\"cpu\":${CPU},\"image\":\"${PUBLISH_NAME}/${PACKAGE_NAME}\",\"name\":\"${FAMILY}\",\"portMappings\":[{\"containerPort\":${APP_PORT},\"hostPort\":${APP_PORT}}]}]")
TASK_REVISION=$(echo "${TASK_REVISION_RAW}" | jq '.[] | .revision')
DESIRED_COUNT_RAW=$(aws ecs describe-services --region ${AWS_REGION} --cluster "${CLUSTER_NAME}" --services "${SERVICE_NAME}")
DESIRED_COUNT=$(echo "${DESIRED_COUNT_RAW}" | jq '.[] | .[] | .desiredCount')
aws ecs update-service --region ${AWS_REGION} --cluster "${CLUSTER_NAME}" --service "${SERVICE_NAME}" --task-definition "${FAMILY}":"${TASK_REVISION}" --desired-count "${DESIRED_COUNT}"
echo "Deployment of ${PACKAGE_NAME} to ECS cluster with task definition ${FAMILY}:${TASK_REVISION} is complete"
