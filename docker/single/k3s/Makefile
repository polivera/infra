deploy:
	docker compose up -d
	cp ./.docker/kubeconfig/kubeconfig.yaml ~/.kube/k3s-config
	sed -i '' 's/127.0.0.1:6443/localhost:6443/' ~/.kube/k3s-config