#!/bin/bash

cd /tmp
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo start amazon-ssm-agent

echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config