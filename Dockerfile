FROM databricksruntime/standard:13.3-LTS as base
RUN /databricks/python3/bin/pip install pandas urllib3
RUN apt-get -y update && apt-get -y install git
RUN git clone  --recurse-submodules https://github.com/CMSgov/price-transparency-guide-validator.git
WORKDIR /price-transparency-guide-validator
RUN npm install -g cms-mrf-validator
FROM ubuntu as build

ARG VERSION=v1.0.0
RUN apt-get update
RUN apt-get install -y g++ cmake doxygen valgrind wget
COPY ./schemavalidator.cpp /
COPY ./rapidjson /rapidjson
COPY ./tclap /tclap
RUN g++ -O3 --std=c++17 -I /rapidjson/include -I /tclap/include/ schemavalidator.cpp -o validator -lstdc++fs

FROM base
COPY --from=build /validator /validator
ENTRYPOINT ["/bin/bash"]
