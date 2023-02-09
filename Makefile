build:
	docker build -t inventicon/doom-rtsp .

run: build
	docker run --rm -it -p 8554:8554 inventicon/doom-rtsp

play:
	ffplay rtsp://localhost:8554/doom
