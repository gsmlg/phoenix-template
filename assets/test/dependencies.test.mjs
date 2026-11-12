import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";

const manifest = JSON.parse(readFileSync(new URL("../package.json", import.meta.url)));
const lock = JSON.parse(readFileSync(new URL("../package-lock.json", import.meta.url)));

test("lockfile matches the supported UI cohort", () => {
  assert.deepEqual(lock.packages[""].dependencies, manifest.dependencies);
  assert.deepEqual(lock.packages[""].devDependencies, manifest.devDependencies);
  for (const [name, version] of Object.entries({ ...manifest.dependencies, ...manifest.devDependencies })) {
    assert.equal(lock.packages[`node_modules/${name}`].version, version);
  }
});
test("registry packages have integrity hashes and use the official HTTPS registry", () => {
  for (const [name, pkg] of Object.entries(lock.packages)) {
    if (!name) continue;
    assert.match(pkg.resolved, /^https:\/\/registry\.npmjs\.org\//, name);
    assert.match(pkg.integrity, /^sha512-/, name);
  }
});
test("all resolved DOMPurify versions include the 3.4.17 security fixes", () => {
  const versions = Object.entries(lock.packages)
    .filter(([name]) => name.endsWith("node_modules/dompurify"))
    .map(([, pkg]) => pkg.version);
  assert.ok(versions.length > 0);
  for (const version of versions) {
    const [major, minor, patch] = version.split(".").map(Number);
    assert.ok(major > 3 || (major === 3 && (minor > 4 || (minor === 4 && patch >= 17))), version);
  }
});
