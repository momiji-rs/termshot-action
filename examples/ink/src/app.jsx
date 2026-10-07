// A small Ink program for the termshot-action guide: the services of a deploy,
// with their status. The arrow keys move the selection.
import React, {useState} from 'react';
import {Box, Text, useInput} from 'ink';

export const services = [
  {name: 'api', status: 'live'},
  {name: 'web', status: 'live'},
  {name: 'worker', status: 'live'},
  {name: 'cron', status: 'pending'},
];

const look = {
  live: {mark: '✓', color: 'green'},
  failed: {mark: '✗', color: 'red'},
  pending: {mark: '●', color: 'yellow'},
};

export function App() {
  const [selected, setSelected] = useState(0);
  useInput((_, key) => {
    if (key.upArrow) setSelected(i => (i + services.length - 1) % services.length);
    if (key.downArrow) setSelected(i => (i + 1) % services.length);
  });
  const live = services.filter(s => s.status === 'live').length;
  return (
    <Box flexDirection="column" width={36}>
      <Box borderStyle="round" borderColor="cyan" flexDirection="column" paddingX={1}>
        <Text bold color="cyan">Deploy #17</Text>
        {services.map((s, i) => (
          <Text key={s.name} inverse={i === selected}>
            <Text color={look[s.status].color}>{look[s.status].mark}</Text> {s.name.padEnd(12)}
            <Text dimColor>{s.status}</Text>
          </Text>
        ))}
      </Box>
      <Text>{live}/{services.length} live · ↑/↓ move</Text>
    </Box>
  );
}
