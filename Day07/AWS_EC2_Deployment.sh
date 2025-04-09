#!/bin/bash

#AWS_EC2_Deployment:


- name: Deploy to AWS EC2
  env:
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    AWS_REGION: us-east-1
  run: |
    # Example of SSH into an EC2 instance and deploy
    ssh -i /path/to/your-key.pem ec2-user@your-ec2-instance "cd /var/www/app && git pull && npm install && npm run build"

