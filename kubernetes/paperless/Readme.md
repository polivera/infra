## Install Paperless

### Run file with env
`env $(cat .env) envsubst < 01-config.yml | kubectl apply -f -`