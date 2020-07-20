dashboards:
	docker-compose -f test/docker/docker-compose.dashboard.yml up -d --build

update-dashboards:
	./test/docker/grafana/update-dashboards.sh

.PHONY: run update-dashboards

clean-dashboards:
	docker-compose -f test/docker/docker-compose.dashboard.yml down
