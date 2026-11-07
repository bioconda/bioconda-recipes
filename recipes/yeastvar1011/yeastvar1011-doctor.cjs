#!/usr/bin/env node
'use strict';
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const root = path.resolve(__dirname, '..', 'share', 'yeastvar1011');
const args = process.argv.slice(2);
try {
  if (args.includes('--help') || args.includes('-h')) {
    console.log('YeastVar1011 installed-workbench check\nUsage: yeastvar1011-doctor [--port N] [--json]\n       yeastvar1011-doctor --help | --version\nChecks the installed files, runtime, and loopback port without changing user data.');
  } else if (args.length === 1 && args[0] === '--version') {
    console.log(require(path.join(root, 'package.json')).version);
  } else {
    const result = spawnSync(process.execPath, [path.join(root, 'scripts/doctor.cjs'), ...args], { stdio: 'inherit' });
    if (result.error) throw result.error;
    process.exitCode = result.status == null ? 1 : result.status;
  }
} catch (error) { console.error(error.message); process.exitCode = 1; }
