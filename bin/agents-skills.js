#!/usr/bin/env node

const { spawnSync } = require('child_process');
const path = require('path');

const installScript = path.join(__dirname, '..', 'install.sh');
const args = process.argv.slice(2);

const result = spawnSync('bash', [installScript, ...args], { stdio: 'inherit' });

if (result.error) {
  console.error("Failed to execute install.sh:", result.error);
  process.exit(1);
}

process.exit(result.status !== null ? result.status : 1);
