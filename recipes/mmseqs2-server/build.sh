#!/bin/bash

cd backend
go build -o ./mmseqs-server
install -d "${PREFIX}/bin"
install mmseqs-server "${PREFIX}/bin/"
