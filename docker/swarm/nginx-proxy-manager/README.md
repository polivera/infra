# Nginx Reverse Proxy

## How to deploy
To deploy this stack run the following command
```bash
env $(cat .env) docker stack deploy -c docker-compose.yml nginx-proxy-manager
```
