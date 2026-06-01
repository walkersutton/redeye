import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";

export const OutroCard: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const fadeIn = interpolate(frame, [0, 25], [0, 1], { extrapolateRight: "clamp" });
  const dotScale = spring({ frame, fps, from: 0, to: 1, config: { damping: 14, stiffness: 120 }, delay: 5 });
  const textOpacity = interpolate(frame, [15, 35], [0, 1], { extrapolateRight: "clamp" });
  const linkOpacity = interpolate(frame, [30, 50], [0, 1], { extrapolateRight: "clamp" });

  return (
    <AbsoluteFill
      style={{
        opacity: fadeIn,
        background: "linear-gradient(135deg, #0a0a0a 0%, #1a0404 50%, #0a0a0a 100%)",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
      }}
    >
      <div
        style={{
          transform: `scale(${dotScale})`,
          width: 80,
          height: 80,
          borderRadius: "50%",
          background: "radial-gradient(circle at 38% 38%, #ff6b6b, #cc0000 55%, #7a0000)",
          boxShadow: "0 0 40px 12px rgba(200,0,0,0.3)",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          marginBottom: 32,
        }}
      >
        <div style={{ width: 30, height: 30, borderRadius: "50%", background: "radial-gradient(circle at 35% 35%, #2a0000, #000)" }} />
      </div>

      <div
        style={{
          opacity: textOpacity,
          fontFamily: "'SF Pro Display', 'Helvetica Neue', Arial, sans-serif",
          fontSize: 64,
          fontWeight: 700,
          letterSpacing: "-2px",
          color: "#fff",
        }}
      >
        redeye
      </div>

      <div
        style={{
          opacity: textOpacity,
          marginTop: 14,
          fontFamily: "'SF Pro Text', 'Helvetica Neue', Arial, sans-serif",
          fontSize: 22,
          fontWeight: 400,
          color: "rgba(255,255,255,0.45)",
        }}
      >
        never get surprised by a dead laptop
      </div>

      <div
        style={{
          opacity: linkOpacity,
          marginTop: 36,
          fontFamily: "'SF Pro Text', 'Helvetica Neue', Arial, sans-serif",
          fontSize: 17,
          fontWeight: 500,
          color: "rgba(255,80,80,0.85)",
          letterSpacing: "0.2px",
        }}
      >
        github.com/walkersutton/redeye
      </div>
    </AbsoluteFill>
  );
};
