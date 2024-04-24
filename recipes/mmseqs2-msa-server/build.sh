#!/bin/bash

cd backend
go build -o ./msa-server
install -d "${PREFIX}/bin"
install msa-server "${PREFIX}/bin/"
