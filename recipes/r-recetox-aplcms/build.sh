#!/bin/bash

$R CMD INSTALL --build --configure_vars "RGL_USE_NULL=TRUE" .
