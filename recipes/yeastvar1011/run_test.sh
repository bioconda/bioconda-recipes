#!/bin/sh
set -eu
yeastvar1011 --help
yeastvar1011 --version
yeastvar1011-doctor --help
yeastvar1011-doctor --version
yeastvar1011-doctor --port 0 --json
node <<'NODE'
'use strict';
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { spawn } = require('node:child_process');
const { once } = require('node:events');
const prefix = process.env.PREFIX;
assert(prefix, 'Conda test PREFIX is required');
const app = path.join(prefix, 'share/yeastvar1011');
const expectedVersion = require(path.join(app, 'package.json')).version;
assert(expectedVersion);
for (const file of ['LICENSE', 'THIRD_PARTY_NOTICES.md', 'DATA_SOURCES.md', 'dist/vendor/katex/fonts/OFL.txt', 'dist/vendor/citations/CPAL-1.0.txt']) {
  assert(fs.statSync(path.join(app, file)).size > 0, file);
}
const child = spawn(process.execPath, [path.join(prefix, 'bin/yeastvar1011'), '--port', '0', '--base-path', '/test/'], { stdio: ['ignore', 'pipe', 'pipe'] });
let text = '';
(async () => {
  try {
    const address = await new Promise((resolve, reject) => {
      const timer = setTimeout(() => reject(new Error('Installed server startup timed out')), 15000);
      child.stdout.on('data', bytes => {
        text += bytes;
        const match = text.match(/YeastVar1011 ready: (http:\/\/127\.0\.0\.1:\d+\/test\/)/);
        if (match) { clearTimeout(timer); resolve(match[1]); }
      });
      child.stderr.on('data', bytes => { text += bytes; });
      child.once('error', error => { clearTimeout(timer); reject(error); });
      child.once('exit', code => { clearTimeout(timer); reject(new Error('Server exited: ' + code + '\n' + text)); });
    });
    const index = await fetch(address);
    assert.equal(index.status, 200);
    assert((await index.text()).includes('YeastVar1011'));
    for (const file of ['data/markers.json', 'vendor/three.module.js', 'vendor/katex/fonts/OFL.txt', 'vendor/citations/citeproc.js']) {
      const response = await fetch(address + file); assert.equal(response.status, 200, file);
      await response.arrayBuffer();
    }
    const manifest = await (await fetch(address + 'data/markers.json')).json();
    for (const shard of manifest.shards || []) {
      const response = await fetch(address + 'data/' + shard); assert.equal(response.status, 200, shard); await response.arrayBuffer();
    }
    console.log('Installed package: HTTP, project subpath, marker shards, renderer, and licenses passed.');
  } finally {
    if (child.exitCode === null) {
      const stopped = once(child, 'exit'); child.kill('SIGTERM');
      const timer = setTimeout(() => child.kill('SIGKILL'), 5000);
      await stopped; clearTimeout(timer);
    }
  }
})().catch(error => { console.error(error.stack); process.exitCode = 1; });
NODE
