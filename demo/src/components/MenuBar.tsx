
interface Props {
  batteryPct: number;
  isCharging: boolean;
  clockTime: string;
}

const getBatteryColor = (pct: number, isCharging: boolean) => {
  if (isCharging) return "#30d158";
  if (pct <= 10) return "#ff453a";
  if (pct <= 20) return "#ff9f0a";
  return "rgba(255,255,255,0.85)";
};

const BatteryIcon: React.FC<{ pct: number; isCharging: boolean }> = ({ pct, isCharging }) => {
  const color = getBatteryColor(pct, isCharging);
  const fillWidth = Math.max(0, Math.min(1, pct / 100));

  return (
    <div style={{ display: "flex", alignItems: "center", gap: 5 }}>
      <svg width="25" height="13" viewBox="0 0 25 13">
        <rect x="0.5" y="0.5" width="21" height="12" rx="3" ry="3"
          stroke={color} strokeWidth="1.2" fill="none" />
        <rect x="22" y="4" width="2.5" height="5" rx="1.2" fill={color} />
        <rect x="2" y="2" width={Math.max(0.5, 17 * fillWidth)} height="9" rx="1.5" fill={color} />
        {isCharging && (
          <text x="7.5" y="11" fontSize="9" fill="#000" fontWeight="bold">⚡</text>
        )}
      </svg>
      <span style={{
        fontFamily: "'SF Pro Text', 'Helvetica Neue', sans-serif",
        fontSize: 13,
        fontWeight: 500,
        color,
        fontVariantNumeric: "tabular-nums",
        display: "inline-block",
        width: 42,
        textAlign: "right",
      }}>
        {pct}%
      </span>
    </div>
  );
};

export const MenuBar: React.FC<Props> = ({ batteryPct, isCharging, clockTime }) => {
  return (
    <div
      style={{
        position: "absolute",
        top: 0,
        left: 0,
        right: 0,
        height: 28,
        background: "rgba(18,8,8,0.78)",
        backdropFilter: "blur(20px)",
        display: "flex",
        alignItems: "center",
        justifyContent: "space-between",
        paddingLeft: 16,
        paddingRight: 16,
        zIndex: 100,
        borderBottom: "1px solid rgba(255,255,255,0.06)",
      }}
    >
      {/* Left: Apple + app menus */}
      <div style={{ display: "flex", alignItems: "center", gap: 20 }}>
        <span style={{ fontFamily: "'SF Pro Text', sans-serif", fontSize: 15, color: "rgba(255,255,255,0.85)", fontWeight: 600 }}></span>
        <span style={{ fontFamily: "'SF Pro Text', sans-serif", fontSize: 13, color: "rgba(255,255,255,0.85)", fontWeight: 700 }}>Word</span>
        {["File", "Edit", "Format", "View"].map((m) => (
          <span key={m} style={{ fontFamily: "'SF Pro Text', sans-serif", fontSize: 13, color: "rgba(255,255,255,0.55)", fontWeight: 400 }}>{m}</span>
        ))}
      </div>

      {/* Right: status area */}
      <div style={{ display: "flex", alignItems: "center", gap: 16 }}>
        {/* redeye menu bar icon — eye silhouette, no background */}
        <svg width="18" height="12" viewBox="0 0 18 12" fill="none">
          <path d="M9 1C5 1 1.5 4 0.5 6C1.5 8 5 11 9 11C13 11 16.5 8 17.5 6C16.5 4 13 1 9 1Z"
            stroke="rgba(255,255,255,0.85)" strokeWidth="1.2" fill="none" strokeLinejoin="round" />
          <circle cx="9" cy="6" r="2.4" stroke="rgba(255,255,255,0.85)" strokeWidth="1.2" fill="none" />
          <circle cx="9" cy="6" r="0.9" fill="rgba(255,255,255,0.85)" />
        </svg>

        {/* Wi-Fi */}
        <svg width="16" height="12" viewBox="0 0 16 12" fill="none">
          <circle cx="8" cy="10.5" r="1.2" fill="rgba(255,255,255,0.75)" />
          <path d="M5.2 7.8 Q8 5.2 10.8 7.8" stroke="rgba(255,255,255,0.75)" strokeWidth="1.2" strokeLinecap="round" fill="none" />
          <path d="M2.5 5 Q8 1 13.5 5" stroke="rgba(255,255,255,0.45)" strokeWidth="1.2" strokeLinecap="round" fill="none" />
        </svg>

        <BatteryIcon pct={batteryPct} isCharging={isCharging} />

        <span style={{
          fontFamily: "'SF Pro Text', 'Helvetica Neue', sans-serif",
          fontSize: 13,
          fontWeight: 500,
          color: "rgba(255,255,255,0.85)",
          fontVariantNumeric: "tabular-nums",
          display: "inline-block",
          width: 64,
          textAlign: "right",
        }}>
          {clockTime}
        </span>
      </div>
    </div>
  );
};
