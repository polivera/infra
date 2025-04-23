# Nextcloud

## How to deploy
To deploy this stack run the following command
```bash
env $(cat .env) docker stack deploy -c docker-compose.yml nextcloud
```

## OCC Commands
To run occ commands for now you have to ssh to the node where nextcloud is running and:
```bash
docker exec -u www-data $(docker ps -q -f name=nextcloud) php occ files:scan --all
```

