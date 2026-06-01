import {
  AbsoluteFill,
  interpolate,
  useCurrentFrame,
  Easing,
} from "remotion";
import { DesktopScene } from "./scenes/DesktopScene";

// Scene timing (frames @ 30fps)
// Battery hits 13% at frame 66. From there, drain runs at half speed.
// 13→4% originally took 54 frames; at half speed it takes 108 → plug-in at frame 174.
// 10% overlay threshold: 1/3 of the way from frame 66 to 174 = frame 102.
// Charge-back: 30 frames (normal speed) → video ends at frame 204 (6.8s).
export const SCENE_OVERLAY_START = 102; // battery hits 10%, redeye kicks in
export const SCENE_PLUGIN_START = 174;  // user plugs in at 4% battery

const ZOOM_IN_START = 20;
const ZOOM_IN_END = 55;
const ZOOM_OUT_START = SCENE_PLUGIN_START;
const ZOOM_OUT_END = 222; // zoom fully out when battery hits 8% (half-speed charge phase ends)

// Clock: 1% battery = 1 minute. Start 9:00 AM.
// Drain 100→4% = 96 min → 10:36 AM. Charge 4→100% = 96 min → 12:12 PM.
const CLOCK_DRAIN_START = 9 * 60;
const CLOCK_DRAIN_END = 9 * 60 + 96;
const TOTAL_FRAMES = 240;

export const RedeyeDemo: React.FC = () => {
  const frame = useCurrentFrame();

  // Battery drain: normal speed 100→13, then HALF SPEED 13→4 (108 frames for 9%).
  // Charge: HALF SPEED 4→8 (48 frames, same rate), then fast 8→100.
  const batteryPct = interpolate(
    frame,
    [0, 20, 66, SCENE_PLUGIN_START, 222, TOTAL_FRAMES],
    [100, 50, 13, 4, 8, 100],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" }
  );

  const isCharging = frame >= SCENE_PLUGIN_START;

  // Clock driven by battery — 1% = 1 min, always in sync regardless of frame rate
  const clockMinutes = isCharging
    ? CLOCK_DRAIN_END + (batteryPct - 4)
    : CLOCK_DRAIN_START + (100 - batteryPct);

  const clockHour = Math.floor(clockMinutes / 60) % 24;
  const clockMin = Math.floor(clockMinutes % 60);
  const h12 = clockHour % 12 || 12;
  const ampm = clockHour >= 12 ? "PM" : "AM";
  const clockTime = `${h12}:${String(clockMin).padStart(2, "0")} ${ampm}`;

  // Overlay: ramps 0→max as battery drops 10→0%, clears fast on charge
  const threshold = 10;
  const maxAlpha = 0.78;
  const rawAlpha = (!isCharging && batteryPct <= threshold)
    ? ((threshold - batteryPct) / threshold) * maxAlpha
    : 0;

  const fadeInMult = interpolate(
    frame,
    [SCENE_OVERLAY_START, SCENE_OVERLAY_START + 25],
    [0, 1],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: Easing.out(Easing.ease) }
  );
  const fadeOutMult = interpolate(
    frame,
    [SCENE_PLUGIN_START, SCENE_PLUGIN_START + 22],
    [1, 0],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: Easing.inOut(Easing.ease) }
  );
  const overlayAlpha = rawAlpha * fadeInMult * fadeOutMult;

  // Zoom into top-right corner (battery indicator), out on charge
  const zoomScale = interpolate(
    frame,
    [ZOOM_IN_START, ZOOM_IN_END, ZOOM_OUT_START, ZOOM_OUT_END],
    [1.0, 2.6, 2.6, 1.0],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: Easing.inOut(Easing.cubic) }
  );

  return (
    <AbsoluteFill
      style={{
        background: "#0a0a14",
        transform: `scale(${zoomScale})`,
        transformOrigin: "right top",
      }}
    >
      <DesktopScene
        batteryPct={Math.round(batteryPct)}
        isCharging={isCharging}
        overlayAlpha={overlayAlpha}
        clockTime={clockTime}
      />
    </AbsoluteFill>
  );
};
