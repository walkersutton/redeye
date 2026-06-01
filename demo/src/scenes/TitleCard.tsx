import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";

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
      {/* App icon — red eye circle */}
      <div
        style={{
          transform: `scale(${dotScale})`,
          width: 120,
          height: 120,
          borderRadius: "50%",
          background: "radial-gradient(circle at 38% 38%, #ff6b6b, #cc0000 55%, #7a0000)",
          boxShadow: "0 0 60px 20px rgba(200,0,0,0.35), 0 0 120px 40px rgba(200,0,0,0.15)",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          marginBottom: 40,
        }}
      >
        {/* pupil */}
        <div
          style={{
            width: 44,
            height: 44,
            borderRadius: "50%",
            background: "radial-gradient(circle at 35% 35%, #2a0000, #000)",
            boxShadow: "inset 0 0 10px rgba(0,0,0,0.8)",
          }}
        />
      </div>

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
