// Generates Main.dc.html — the spinnable wheel screen.
// The wheel SVG (6 core / 34 middle / 68 outer wedges + radial labels) is
// precomputed here as literal markup; rotation + selection are runtime state.
import { writeFileSync } from 'node:fs';

const CX = 195, CY = 270;
const R_HUB = 50, R_CORE = 108, R_MID = 172, R_OUT = 248;
const INK = '#3a3244';

// Clockwise from top, matching the classic feelings wheel.
const CORES = [
  { name: 'Anger', cols: ['#df86dd', '#ecaeea', '#f6d7f5'], mids: [
    ['Rage', ['Hate', 'Hostile']],
    ['Exasperated', ['Agitated', 'Frustrated']],
    ['Irritable', ['Annoyed', 'Aggravated']],
    ['Envy', ['Resentful', 'Jealous']],
    ['Disgust', ['Contempt', 'Revolted']],
  ]},
  { name: 'Sadness', cols: ['#9fa9e6', '#bfc6ef', '#e0e3f8'], mids: [
    ['Suffering', ['Agony', 'Hurt']],
    ['Sadness', ['Depressed', 'Sorrow']],
    ['Disappointed', ['Dismayed', 'Displeased']],
    ['Shameful', ['Regretful', 'Guilty']],
    ['Neglected', ['Isolated', 'Lonely']],
    ['Despair', ['Grief', 'Powerless']],
  ]},
  { name: 'Surprise', cols: ['#7fdcc0', '#a8e8d4', '#d6f4ea'], mids: [
    ['Stunned', ['Shocked', 'Dismayed']],
    ['Confused', ['Disillusioned', 'Perplexed']],
    ['Amazed', ['Astonished', 'Awe-struck']],
    ['Overcome', ['Speechless', 'Astounded']],
    ['Moved', ['Stimulated', 'Touched']],
  ]},
  { name: 'Joy', cols: ['#a8d97a', '#c6e6a2', '#e4f3d2'], mids: [
    ['Content', ['Pleased', 'Satisfied']],
    ['Happy', ['Amused', 'Delighted']],
    ['Cheerful', ['Jovial', 'Blissful']],
    ['Proud', ['Triumphant', 'Illustrious']],
    ['Optimistic', ['Eager', 'Hopeful']],
    ['Enthusiastic', ['Excited', 'Zeal']],
    ['Elation', ['Euphoric', 'Jubilation']],
    ['Enthralled', ['Enchanted', 'Rapture']],
  ]},
  { name: 'Love', cols: ['#e9d377', '#f1e4a4', '#f9f2d4'], mids: [
    ['Affectionate', ['Romantic', 'Fondness']],
    ['Longing', ['Sentimental', 'Attracted']],
    ['Desire', ['Passion', 'Infatuation']],
    ['Tenderness', ['Caring', 'Compassionate']],
    ['Peaceful', ['Relieved', 'Satisfied']],
  ]},
  { name: 'Fear', cols: ['#ec9b85', '#f3bcac', '#fadfd7'], mids: [
    ['Scared', ['Frightened', 'Helpless']],
    ['Terror', ['Panic', 'Hysterical']],
    ['Insecure', ['Inferior', 'Inadequate']],
    ['Nervous', ['Worried', 'Anxious']],
    ['Horror', ['Mortified', 'Dread']],
  ]},
];

const RAD = Math.PI / 180;
const pt = (r, a) => `${(CX + r * Math.cos(a * RAD)).toFixed(2)} ${(CY + r * Math.sin(a * RAD)).toFixed(2)}`;
const wedge = (a0, a1, r0, r1) =>
  `M ${pt(r1, a0)} A ${r1} ${r1} 0 0 1 ${pt(r1, a1)} L ${pt(r0, a1)} A ${r0} ${r0} 0 0 0 ${pt(r0, a0)} Z`;
const esc = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

function label(text, midA, r, size, fill, extra = '') {
  const x = (CX + r * Math.cos(midA * RAD)).toFixed(2);
  const y = (CY + r * Math.sin(midA * RAD)).toFixed(2);
  const norm = ((midA % 360) + 360) % 360;
  const rot = (norm > 90 && norm < 270) ? midA + 180 : midA;
  return `<text x="${x}" y="${y}" transform="rotate(${rot.toFixed(2)} ${x} ${y})" text-anchor="middle" dominant-baseline="middle" font-size="${size}" fill="${fill}" ${extra}>${esc(text)}</text>`;
}

const totalMids = CORES.reduce((n, c) => n + c.mids.length, 0);
const unit = 360 / totalMids;
let cursor = -90 - (CORES[0].mids.length * unit) / 2;

const parts = [];
const data = { cores: [] };

for (const core of CORES) {
  const span = core.mids.length * unit;
  const c0 = cursor, c1 = cursor + span;
  const d = { name: core.name, start: c0, end: c1, cols: core.cols, outers: [] };
  parts.push(`<path d="${wedge(c0, c1, R_HUB, R_CORE)}" fill="${core.cols[0]}" stroke="#faf7f2" stroke-width="1.2"/>`);
  let m = c0;
  for (const [midName, outers] of core.mids) {
    const m1 = m + unit;
    parts.push(`<path d="${wedge(m, m1, R_CORE, R_MID)}" fill="${core.cols[1]}" stroke="#faf7f2" stroke-width="1.2"/>`);
    const ow = unit / outers.length;
    let o = m;
    for (const outerName of outers) {
      const o1 = o + ow;
      const key = `${core.name}/${outerName}`;
      parts.push(`<path d="${wedge(o, o1, R_MID, R_OUT)}" fill="${core.cols[2]}" stroke="#faf7f2" stroke-width="1.2" data-f="${esc(key)}" style="cursor:pointer"/>`);
      parts.push(label(outerName, o + ow / 2, (R_MID + R_OUT) / 2, 10.5, '#3f3749', `data-f="${esc(key)}" style="cursor:pointer"`));
      d.outers.push({ key, name: outerName, mid: midName, a0: +o.toFixed(3), a1: +o1.toFixed(3) });
      o = o1;
    }
    parts.push(label(midName, m + unit / 2, (R_CORE + R_MID) / 2, 10, '#4c4356'));
    m = m1;
  }
  parts.push(label(core.name, c0 + span / 2, (R_HUB + R_CORE) / 2, 14.5, INK,
    'font-family="Instrument Serif, Georgia, serif" font-style="italic"'));
  data.cores.push(d);
  cursor = c1;
}

const wheelMarkup = parts.join('\n      ');

const html = `<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <script src="./support.js"></script>
</head>
<body>
<x-dc>
<helmet>
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1&amp;family=Instrument+Sans:wght@400;500;600&amp;display=swap">
  <style>
    body { margin: 0; background: #faf7f2; font-family: 'Instrument Sans', system-ui, sans-serif; color: #3a3244; }
    a { color: #8a5fb0; } a:hover { color: #6d4691; }
  </style>
</helmet>
<div style="width: 390px; height: 844px; background: #faf7f2; display: flex; flex-direction: column; overflow: hidden">
  <div style="padding: 56px 24px 2px 24px">
    <div style="font-size: 11px; letter-spacing: 3px; font-weight: 600; color: #9a8fa6">ATTUNE</div>
    <div style="font-family: 'Instrument Serif', Georgia, serif; font-size: 25px; margin-top: 4px">How are you feeling?</div>
  </div>
  <svg width="390" height="396" viewBox="0 0 390 396" onPointerDown="{{down}}" onPointerMove="{{move}}" onPointerUp="{{up}}" onPointerLeave="{{up}}" onClick="{{tap}}" style="touch-action: none; cursor: grab; display: block; font-family: 'Instrument Sans', system-ui, sans-serif; filter: drop-shadow(0 10px 24px rgba(70, 48, 92, 0.14))">
    <g transform="{{gt}}">
      ${wheelMarkup}
      <path d="{{selPath}}" fill="none" stroke="#3a3244" stroke-width="2.5"/>
    </g>
    <circle cx="195" cy="270" r="50" fill="#fffdf9" stroke="rgba(58,50,68,0.12)" stroke-width="1"/>
    <text x="195" y="266" text-anchor="middle" font-family="Instrument Serif, Georgia, serif" font-style="italic" font-size="19" fill="#3a3244">{{focusName}}</text>
    <text x="195" y="287" text-anchor="middle" font-size="9.5" letter-spacing="1.5" fill="#9a8fa6">SPIN ME</text>
    <polygon points="186,6 204,6 195,22" fill="#3a3244"/>
  </svg>
  <div style="padding: 12px 24px 0 24px; display: flex; align-items: baseline; gap: 8px">
    <span style="font-family: 'Instrument Serif', Georgia, serif; font-size: 19px">{{focusName}}</span>
    <span style="font-size: 12px; color: #9a8fa6">{{focusSub}}</span>
  </div>
  <div style="flex: 1 1 0; overflow-y: auto; padding: 10px 24px 8px 24px; display: flex; flex-wrap: wrap; gap: 8px; align-content: flex-start">
    <sc-for list="{{chips}}" as="c" hint-placeholder-count="10">
      <div onClick="{{c.pick}}" style="padding: 14px 17px; border-radius: 999px; font-size: 14px; line-height: 16px; cursor: pointer; {{c.st}}">{{c.name}}</div>
    </sc-for>
  </div>
  <div style="padding: 12px 24px 28px 24px">
    <div style="background: #332c3e; color: #faf7f2; border-radius: 18px; height: 58px; display: flex; align-items: center; justify-content: space-between; padding: 0 22px; font-size: 16px; font-weight: 600; cursor: pointer">
      <span>What&#39;s beneath {{selName}}?</span>
      <svg width="20" height="20" viewBox="0 0 20 20"><path d="M4 10 H16 M11 4.5 L16.5 10 L11 15.5" fill="none" stroke="#faf7f2" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>
    </div>
  </div>
</div>
</x-dc>
<script data-dc-script data-props='{"$preview":{"width":390,"height":844}}'>
const W = ${JSON.stringify(data)};

class Component extends DCLogic {
  cur() { return this.state || {}; }
  rotNow() { const s = this.cur(); return typeof s.rot === 'number' ? s.rot : 0; }
  focusCore() {
    let a = (-90 - this.rotNow()) % 360; a = (a + 360) % 360;
    for (const c of W.cores) {
      const s = ((c.start % 360) + 360) % 360;
      let aa = a; if (aa < s) aa += 360;
      if (aa >= s && aa < s + (c.end - c.start)) return c;
    }
    return W.cores[0];
  }
  wedgePath(a0, a1, r0, r1) {
    const RAD = Math.PI / 180;
    const px = (r, a) => (195 + r * Math.cos(a * RAD)).toFixed(2) + ' ' + (270 + r * Math.sin(a * RAD)).toFixed(2);
    return 'M ' + px(r1, a0) + ' A ' + r1 + ' ' + r1 + ' 0 0 1 ' + px(r1, a1) +
      ' L ' + px(r0, a1) + ' A ' + r0 + ' ' + r0 + ' 0 0 0 ' + px(r0, a0) + ' Z';
  }
  angleAt(e) {
    const rect = e.currentTarget.getBoundingClientRect();
    const cx = rect.left + rect.width * (195 / 390);
    const cy = rect.top + rect.height * (270 / 396);
    return Math.atan2(e.clientY - cy, e.clientX - cx) * 180 / Math.PI;
  }
  renderVals() {
    const self = this;
    const s = this.cur();
    const pick = s.pick === undefined ? 'Anger/Frustrated' : s.pick;
    const fc = this.focusCore();
    let selPath = '', selName = pick.split('/')[1];
    for (const c of W.cores) for (const o of c.outers) {
      if (o.key === pick) selPath = this.wedgePath(o.a0, o.a1, 172, 248);
    }
    return {
      gt: 'rotate(' + this.rotNow().toFixed(2) + ' 195 270)',
      selPath: selPath,
      selName: selName,
      focusName: fc.name,
      focusSub: fc.outers.length + ' outer feelings — tap one',
      chips: fc.outers.map(function (o) {
        const sel = o.key === pick;
        return {
          name: o.name,
          st: sel
            ? 'background:' + fc.cols[1] + ';border:1.5px solid #3a3244;color:#3a3244;font-weight:600'
            : 'background:#fffdf9;border:1.5px solid #e9e1d5;color:#54495f',
          pick: function () { self.setState({ pick: o.key }); }
        };
      }),
      down: function (e) {
        self._drag = true; self._mv = 0; self._la = self.angleAt(e);
        if (e.currentTarget.setPointerCapture && e.pointerId !== undefined) {
          try { e.currentTarget.setPointerCapture(e.pointerId); } catch (err) {}
        }
      },
      move: function (e) {
        if (!self._drag) return;
        const a = self.angleAt(e);
        let d = a - self._la;
        if (d > 180) d -= 360; if (d < -180) d += 360;
        self._la = a; self._mv = (self._mv || 0) + Math.abs(d);
        self.setState({ rot: self.rotNow() + d });
      },
      up: function () { self._drag = false; },
      tap: function (e) {
        if ((self._mv || 0) > 2) return;
        let t = e.target;
        for (let i = 0; i < 6 && t && t.getAttribute; i++) {
          const k = t.getAttribute('data-f');
          if (k) { self.setState({ pick: k }); return; }
          t = t.parentNode;
        }
      }
    };
  }
}
</script>
</body>
</html>
`;

writeFileSync(new URL('./Main.dc.html', import.meta.url), html);
console.log('Main.dc.html written:', html.length, 'bytes,', data.cores.reduce((n, c) => n + c.outers.length, 0), 'outer feelings');
