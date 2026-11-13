import { AbsoluteFill, Img, interpolate, staticFile, spring, useCurrentFrame, useVideoConfig } from "remotion";

export const TitleCard: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const fadeIn = interpolate(frame, [0, 20], [0, 1], { extrapolateRight: "clamp" });
  const fadeOut = interpolate(frame, [65, 90], [1, 0], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const opacity = Math.min(fadeIn, fadeOut);

  const dotScale = spring({ frame, fps, from: 0, to: 1, config: { damping: 14, stiffness: 120 }, delay: 8 });
  const textY = interpolate(spring({ frame, fps, from: 0, to: 1, config: { damping: 18, stiffness: 100 }, delay: 18 }), [0, 1], [24, 0]);
  const textOpacity = interpolate(frame, [18, 38], [0, 1], { extrapolateRight: "clamp" });
  const subY = interpolate(spring({ frame, fps, from: 0, to: 1, config: { damping: 18, stiffness: 100 }, delay: 30 }), [0, 1], [16, 0]);
  const subOpacity = interpolate(frame, [30, 50], [0, 1], { extrapolateRight: "clamp" });

  return (
    <AbsoluteFill
      style={{
        opacity,
        background: "linear-gradient(135deg, #0a0a0a 0%, #1a0404 50%, #0a0a0a 100%)",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        gap: 0,
      }}
    >
      {/* App icon */}
      <Img
        src={staticFile("redeye-eye-icon.png")}
        style={{
          transform: `scale(${dotScale})`,
          width: 160,
          height: 160,
          filter: "drop-shadow(0 0 40px rgba(232,53,43,0.45))",
          marginBottom: 28,
        }}
      />

      <div
        style={{
          opacity: textOpacity,
          transform: `translateY(${textY}px)`,
          fontFamily: "'SF Pro Display', 'Helvetica Neue', Arial, sans-serif",
          fontSize: 88,
          fontWeight: 700,
          letterSpacing: "-3px",
          color: "#fff",
          lineHeight: 1,
        }}
      >
        redeye
      </div>

      <div
        style={{
          opacity: subOpacity,
          transform: `translateY(${subY}px)`,
          marginTop: 20,
          fontFamily: "'SF Pro Text', 'Helvetica Neue', Arial, sans-serif",
          fontSize: 26,
          fontWeight: 400,
          color: "rgba(255,255,255,0.5)",
          letterSpacing: "0.5px",
        }}
      >
        never get surprised by a dead laptop
      </div>
    </AbsoluteFill>
  );
};
