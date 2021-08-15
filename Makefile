# .PHONY: swiftlint swiftlint-autocorrect
# swiftlint:
# 	swift run -c release --package-path tools swiftlint lint

# swiftlint-autocorrect:
# 	swift run -c release --package-path tools swiftlint autocorrect --format

.PHONY: swift-format swift-format-lint
swift-format:
	swift run -c release --package-path tools swift-format format -r ./Sources -i
swift-format-lint:
	swift run -c release --package-path tools swift-format lint -r ./Sources

.PHONY: serve migrate
serve:
	vapor run serve
migrate:
	vapor run migrate --yes

.PHONY: build up down
build:
	docker-compose build --no-cache
up:
	docker-compose up -d db redis
down:
	docker-compose down
