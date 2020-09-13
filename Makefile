export FULL_VESRION="$$(cat ./VERSION)-regen-dh"
export TESTS_FOLDER=$$(TEMP_VAR=$${TESTS_REPORT:-$${PWD}/tests-report}; echo $${TEMP_VAR})

.PHONY: build build-local build-dev build-test install clean test run

all: build test

build:
	@echo "Making production version ${FULL_VESRION} of DockOvpn"
	docker build -t alekslitvinenk/openvpn:${FULL_VESRION} -t alekslitvinenk/openvpn:latest . --no-cache
	docker push alekslitvinenk/openvpn:${FULL_VESRION}
	docker push alekslitvinenk/openvpn:latest

build-local:
	@echo "Making version of DockOvpn for testing on local machine"
	docker build -t alekslitvinenk/openvpn:local . --no-cache

build-dev:
	@echo "Making development version of DockOvpn"
	docker build -t alekslitvinenk/openvpn:dev . --no-cache
	docker push alekslitvinenk/openvpn:dev

build-test:
	@echo "Making testing version of DockOvpn"
	docker build -t alekslitvinenk/openvpn:test . --no-cache
	docker push alekslitvinenk/openvpn:test

install:
	@echo "Installing DockOvpn ${FULL_VESRION}"

clean:
	@echo "Making cleanup"
	docker rm dockovpn

test:
	@echo "Running tests for DockOvpn ${FULL_VESRION}"
	@echo "Test reports will be saved in ${TESTS_FOLDER}"
	docker run \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v ${TESTS_FOLDER}:/target/test-reports \
	alekslitvinenk/dockovpn-it test
	for entry in $$(ls -d ${TESTS_FOLDER}/*.xml); \
	do \
		mv -f $$entry ${TESTS_FOLDER}/report.xml; \
	done

run:
	docker run --cap-add=NET_ADMIN \
	-v openvpn_conf:/opt/Dockovpn \
	-p 1194:1194/udp -p 80:8080/tcp \
	-e HOST_ADDR=localhost \
	--rm \
	alekslitvinenk/openvpn
