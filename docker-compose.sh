#!/bin/sh

#
#	MetaCall Build Bash Script by Parra Studios
#	Build and install bash script utility for MetaCall.
#
#	Copyright (C) 2016 - 2019 Vicente Eduardo Ferrer Garcia <vic798@gmail.com>
#
#	Licensed under the Apache License, Version 2.0 (the "License");
#	you may not use this file except in compliance with the License.
#	You may obtain a copy of the License at
#
#		http://www.apache.org/licenses/LICENSE-2.0
#
#	Unless required by applicable law or agreed to in writing, software
#	distributed under the License is distributed on an "AS IS" BASIS,
#	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#	See the License for the specific language governing permissions and
#	limitations under the License.
#

# Pull MetaCall Docker Compose
sub_pull() {
	if [ -z "$IMAGE_NAME" ]; then
		echo "Error: IMAGE_NAME variable not defined"
		exit 1
	fi

	docker pull $IMAGE_NAME:deps_node || true

	docker pull $IMAGE_NAME:deps || true

	docker pull $IMAGE_NAME:dev || true

	docker pull $IMAGE_NAME:runtime || true
}

# Build MetaCall Docker Compose (link manually dockerignore files)
sub_build() {
	ln -sf tools/node/.dockerignore .dockerignore
	docker-compose -f docker-compose.yml build --force-rm deps_node

	ln -sf tools/base/.dockerignore .dockerignore
	docker-compose -f docker-compose.yml build --force-rm deps

	ln -sf tools/dev/.dockerignore .dockerignore
	docker-compose -f docker-compose.yml build --force-rm dev

	ln -sf tools/core/.dockerignore .dockerignore
	docker-compose -f docker-compose.yml build --force-rm runtime
}

# Build MetaCall Docker Compose with caching (link manually dockerignore files)
sub_build_cache() {
	if [ -z "$IMAGE_REGISTRY" ]; then
		echo "Error: IMAGE_REGISTRY variable not defined"
		exit 1
	fi

	ln -sf tools/node/.dockerignore .dockerignore
	docker-compose -f docker-compose.yml -f docker-compose.cache.yml build deps_node

	ln -sf tools/base/.dockerignore .dockerignore
	docker-compose -f docker-compose.yml -f docker-compose.cache.yml build deps

	ln -sf tools/dev/.dockerignore .dockerignore
	docker-compose -f docker-compose.yml -f docker-compose.cache.yml build dev

	ln -sf tools/core/.dockerignore .dockerignore
	docker-compose -f docker-compose.yml -f docker-compose.cache.yml build runtime
}

# Push MetaCall Docker Compose
sub_push(){
	if [ -z "$IMAGE_NAME" ]; then
		echo "Error: IMAGE_NAME variable not defined"
		exit 1
	fi

	# Push deps_node image
	docker tag metacall/core:deps_node $IMAGE_NAME:deps_node
	docker push $IMAGE_NAME:deps_node

	# Push deps image
	docker tag metacall/core:deps $IMAGE_NAME:deps
	docker push $IMAGE_NAME:deps

	# Push dev image
	docker tag metacall/core:dev $IMAGE_NAME:dev
	docker push $IMAGE_NAME:dev

	# Push runtime image
	docker tag metacall/core:runtime $IMAGE_NAME:runtime
	docker push $IMAGE_NAME:runtime

	# Push runtime as a latest
	docker tag metacall/core:runtime $IMAGE_NAME:latest
	docker push $IMAGE_NAME:latest
}

# Pack MetaCall Docker Compose
sub_pack(){
	if [ -z "$ARTIFACTS_PATH" ]; then
		echo "Error: ARTIFACTS_PATH variable not defined"
		exit 1
	fi

	# Get path where docker-compose.sh is located
	BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

	# Load default environment variables
	. $BASE_DIR/.env

	# Get layer with the tag METACALL_CLEAR_OPTIONS to hook into the previous layer of the clean command
	DOCKER_HOOK_CLEAR=`docker image history --no-trunc metacall/core:dev | grep 'ARG METACALL_CLEAR_OPTIONS' | awk '{print $1}'`

	# Show the base layer for the build
	echo "Generating the pack from layer: ${DOCKER_HOOK_CLEAR}"

	# Run the package builds
	docker run --name metacall_core_pack -i $DOCKER_HOOK_CLEAR /bin/bash -c 'cd build && make pack'

	# Create artifacts folder
	mkdir -p $ARTIFACTS_PATH

	# Copy artifacts
	docker cp metacall_core_pack:$METACALL_PATH/build/packages $ARTIFACTS_PATH

	# Remove docker instance
	docker rm metacall_core_pack

	# List generated artifacts
	ls -la $ARTIFACTS_PATH/packages
}

# Help
sub_help() {
	echo "Usage: `basename "$0"` option"
	echo "Options:"
	echo "	pull"
	echo "	build"
	echo "	build-cache"
	echo "	push"
	echo "	pack"
	echo ""
}

case "$1" in
	pull)
		sub_pull
		;;
	build)
		sub_build
		;;
	build-cache)
		sub_build_cache
		;;
	push)
		sub_push
		;;
	pack)
		sub_pack
		;;
	*)
		sub_help
		;;
esac
