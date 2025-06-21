## Install Paperless

### Run file with env
`env $(cat .env) envsubst < 01-configs.yml | kubectl apply -f -`