#!/bin/bash

yum install aws-cli -y
echo ECS_CLUSTER=${ecs_cluster_name} > /etc/ecs/ecs.config
start ecs

if (( ${nrpe_server_enabled} == 1 )); then
eval $(aws --region ${region} ecr get-login)
docker run --privileged -d --name nrpe_server --pid host --net host -v /:/host -v /dev:/dev -v /run:/run --restart always --memory-reservation ${nrpe_server_memoryReservation} ${nrpe_server_image}
fi