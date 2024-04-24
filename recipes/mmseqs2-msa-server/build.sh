#!/bin/bash

cd backend
go build -o ./msa-server
install -D msa-server "${PREFIX}/bin/msa-server"
