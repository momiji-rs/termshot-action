import React from 'react';
import {expect, test, vi} from 'vitest';
import {render} from 'ink-testing-library';
import {App} from './app.jsx';

// Presses a key once the app listens for keys, and waits for the frame it draws.
async function press(app, key) {
  await new Promise(resolve => setTimeout(resolve, 0)); // let useInput's effect run
  const before = app.frames.length;
  app.stdin.write(key);
  await vi.waitFor(() => expect(app.frames.length).toBeGreaterThan(before));
}

test('a deploy with a failed service', async () => {
  const app = render(<App />);
  await expect(app.lastFrame()).toMatchFileSnapshot('__screens__/deploy.ansi');
});

test('the selection moves down', async () => {
  const app = render(<App />);
  await press(app, '\u001B[B');
  await expect(app.lastFrame()).toMatchFileSnapshot('__screens__/deploy-down.ansi');
});
