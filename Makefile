usage:
	@echo "Available targets:"
	@echo "  * build - Builds image"
	@echo "  * dev   - Opens an ash session in the container"

.PHONY: build
build:
	docker build . -t stack_trace

.PHONY: dev
dev:
	docker run -it --rm -v $(PWD):/stack_trace stack_trace sh
