platforms=linux/amd64,linux/arm/v7,linux/arm/v6,linux/arm64
build:
	docker build -t inventicon/doom-rtsp .

buildx:
	docker buildx build --platform $(platforms) -t inventicon/doom-rtsp .

run: build
	docker run --rm -it -p 8554:8554 inventicon/doom-rtsp

play:
	ffplay rtsp://localhost:8554/doom
