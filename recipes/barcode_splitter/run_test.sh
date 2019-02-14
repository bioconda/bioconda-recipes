#!/bin/bash

STDOUTTESTONE=`barcode_splitter --version 2>&1`

if [ $? -ne 2 ] || [ "$STDOUTTESTONE" != "barcode_splitter version 0.18.3" ]; then
  exit 1
fi

exit 0