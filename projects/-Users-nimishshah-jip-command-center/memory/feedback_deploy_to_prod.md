---
name: feedback_deploy_to_prod
description: When user says commit and push, always deploy to EC2 prod — not just git push
type: feedback
---

When the user says "commit and push" or "push it", they mean deploy to production on EC2.
Always: git commit → git push → SSH into EC2 → git pull → docker compose up --build -d
Never just push to GitHub and stop. The user expects to see changes live on ops.jslwealth.in.

EC2 deploy command:
ssh -i ~/.ssh/jsl-wealth-key.pem ubuntu@13.206.34.214 "cd /home/ubuntu/jip-command-center && git pull && docker compose up --build -d"
