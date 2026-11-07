#!/usr/bin/env node
'use strict';
const path = require('node:path');
const root = path.resolve(__dirname, '..', 'share', 'yeastvar1011');
const args = process.argv.slice(2);
try {
  if (args.includes('--help') || args.includes('-h')) {
    console.log('YeastVar1011 local research-plan workbench\nUsage: yeastvar1011 [--port N] [--base-path /path/]\n       yeastvar1011 --help | --version\nPort defaults to 4173 or PORT; 0 selects a free port. The server binds to 127.0.0.1.\nOpen the printed URL in a browser. Press Ctrl+C to stop.');
  } else if (args.length === 1 && args[0] === '--version') {
    console.log(require(path.join(root, 'package.json')).version);
  } else {
    for (let i = 0; i < args.length; i++) {
      if (args[i] === '--port' && args[i + 1] != null) {
        process.env.PORT = String(require(path.join(root, 'scripts/doctor.cjs')).parsePort(args[++i]));
      } else if (args[i] === '--base-path' && args[i + 1] != null) {
        process.env.BASE_PATH = args[++i];
      } else throw new Error('Unknown or incomplete option: ' + args[i] + '. See --help.');
    }
    require(path.join(root, 'scripts/dev-server.cjs')).start();
  }
} catch (error) { console.error(error.message); process.exitCode = 1; }
