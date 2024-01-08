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
	docker-compose up -d db
down:
	docker-compose down

.PHONY: generate-redoc
generate-redoc:
	docker run --rm -v ${PWD}/reference:/spec redocly/cli build-docs agqr-radio-program-guide-api.v2.yaml -o redoc-static.html
	mv reference/redoc-static.html Resources/Views/redoc-static.html
