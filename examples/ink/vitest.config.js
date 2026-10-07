import {defineConfig} from 'vitest/config';

export default defineConfig({
  test: {
    // A test has no terminal for chalk to detect colours from: force true colour,
    // or the snapshots lose every colour.
    env: {FORCE_COLOR: '3'},
  },
});
