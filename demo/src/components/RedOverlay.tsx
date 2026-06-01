import { AbsoluteFill } from "remotion";

interface Props {
  alpha: number;
}

export const RedOverlay: React.FC<Props> = ({ alpha }) => {
  if (alpha <= 0) return null;

  return (
    <AbsoluteFill
      style={{
        background: `rgba(255, 0, 0, ${alpha})`,
        pointerEvents: "none",
        zIndex: 50,
        // Subtle vignette to make it feel like a screen tint rather than a flat fill
        backgroundImage: `radial-gradient(ellipse at 50% 50%, rgba(255,0,0,${alpha * 0.7}) 0%, rgba(255,0,0,${alpha}) 100%)`,
      }}
    />
  );
};
