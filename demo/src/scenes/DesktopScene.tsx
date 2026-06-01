import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { MenuBar } from "../components/MenuBar";
import { DocumentWindow } from "../components/DocumentWindow";
import { RedOverlay } from "../components/RedOverlay";
import { SCENE_OVERLAY_START, SCENE_PLUGIN_START } from "../RedeyeDemo";

interface Props {
  batteryPct: number;
  isCharging: boolean;
  overlayAlpha: number;
  clockTime: string;
}

export const DesktopScene: React.FC<Props> = ({
  batteryPct,
  isCharging,
  overlayAlpha,
  clockTime,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Wallpaper deepens red as battery falls below 10%
  const wallpaperRed = interpolate(batteryPct, [0, 10], [32, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill>
      {/* Wallpaper */}
      <AbsoluteFill
        style={{
          background: `linear-gradient(160deg,
            rgb(${13 + wallpaperRed}, 13, 20) 0%,
            rgb(${20 + wallpaperRed}, 20, 40) 40%,
            rgb(${30 + wallpaperRed}, 15, 50) 100%)`,
        }}
      />

      {/* Document window */}
      <DocumentWindow />

      {/* Red overlay — the redeye effect */}
      <RedOverlay alpha={overlayAlpha} />

      {/* Menu bar — always on top */}
      <MenuBar batteryPct={batteryPct} isCharging={isCharging} clockTime={clockTime} />

      {/* Low battery notification */}
      {batteryPct <= 10 && !isCharging && (
        <LowBatteryNotification batteryPct={batteryPct} frame={frame} fps={fps} />
      )}

      {/* Charging notification */}
      {isCharging && (
        <ChargingNotification frame={frame} fps={fps} />
      )}
    </AbsoluteFill>
  );
};

const LowBatteryNotification: React.FC<{ batteryPct: number; frame: number; fps: number }> = ({
  batteryPct,
  frame,
  fps,
}) => {
  const relFrame = frame - SCENE_OVERLAY_START;
  const slideX = interpolate(
    spring({ frame: relFrame, fps, from: 0, to: 1, config: { damping: 16, stiffness: 130 } }),
    [0, 1],
    [380, 0]
  );
  const opacity = interpolate(relFrame, [0, 12], [0, 1], { extrapolateRight: "clamp" });

  return (
    <div style={{
      position: "absolute",
      top: 46,
      right: 20 + slideX,
      opacity,
      background: "rgba(28,28,30,0.95)",
      backdropFilter: "blur(20px)",
      borderRadius: 14,
      padding: "13px 17px",
      display: "flex",
      alignItems: "center",
      gap: 13,
      boxShadow: "0 8px 32px rgba(0,0,0,0.55)",
      border: "1px solid rgba(255,255,255,0.1)",
      minWidth: 300,
      zIndex: 200,
    }}>
      <div style={{ fontSize: 28 }}>🔋</div>
      <div>
        <div style={{ fontFamily: "'SF Pro Text', sans-serif", fontSize: 14, fontWeight: 600, color: "#fff" }}>
          Low Battery
        </div>
        <div style={{ fontFamily: "'SF Pro Text', sans-serif", fontSize: 12, color: "rgba(255,255,255,0.55)", marginTop: 2 }}>
          {batteryPct}% of battery remaining
        </div>
      </div>
    </div>
  );
};

const ChargingNotification: React.FC<{ frame: number; fps: number }> = ({ frame, fps }) => {
  const relFrame = frame - SCENE_PLUGIN_START;
  const slideX = interpolate(
    spring({ frame: relFrame, fps, from: 0, to: 1, config: { damping: 16, stiffness: 130 } }),
    [0, 1],
    [380, 0]
  );
  const opacity = interpolate(relFrame, [0, 12], [0, 1], { extrapolateRight: "clamp" });

  return (
    <div style={{
      position: "absolute",
      top: 46,
      right: 20 + slideX,
      opacity,
      background: "rgba(28,28,30,0.95)",
      backdropFilter: "blur(20px)",
      borderRadius: 14,
      padding: "13px 17px",
      display: "flex",
      alignItems: "center",
      gap: 13,
      boxShadow: "0 8px 32px rgba(0,0,0,0.55)",
      border: "1px solid rgba(255,255,255,0.1)",
      minWidth: 300,
      zIndex: 200,
    }}>
      <div style={{ fontSize: 28 }}>⚡</div>
      <div>
        <div style={{ fontFamily: "'SF Pro Text', sans-serif", fontSize: 14, fontWeight: 600, color: "#fff" }}>
          Charging
        </div>
        <div style={{ fontFamily: "'SF Pro Text', sans-serif", fontSize: 12, color: "rgba(255,255,255,0.55)", marginTop: 2 }}>
          Power adapter connected
        </div>
      </div>
    </div>
  );
};
