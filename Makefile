up:
	docker-compose up -d --build --remove-orphans

build:
	docker-compose build --pull

down:
	docker-compose down --remove-orphans

logs:
	docker-compose logs -f --tail=100
