import { interpolate, useCurrentFrame } from "remotion";

const THESIS_PARAGRAPHS = [
  {
    heading: "Abstract",
    text: "This thesis investigates the relationship between distributed consensus mechanisms and fault-tolerant system design in large-scale cloud architectures. We present a novel framework for analyzing Byzantine fault tolerance under partial synchrony assumptions, demonstrating that classical Paxos-derived protocols exhibit measurable degradation in throughput when confronted with adversarial network conditions exceeding 33% of nodes.",
  },
  {
    heading: "1. Introduction",
    text: "Modern distributed systems face an inherent tension between availability and consistency — a dichotomy formalized in the CAP theorem (Brewer, 2000). While considerable theoretical work has addressed the boundaries of achievable consistency under network partitions, practical deployments continue to struggle with the operational complexity of managing consensus quorums at scale. The proliferation of geo-distributed databases has further complicated matters, introducing latency asymmetries that existing theoretical models inadequately capture.",
  },
  {
    heading: "2. Background",
    text: "The Byzantine Generals Problem, first formalized by Lamport, Shostak, and Pease (1982), describes the challenge of achieving consensus among distributed agents when some participants may act arbitrarily or maliciously. Subsequent work by Castro and Liskov (1999) on Practical Byzantine Fault Tolerance (PBFT) demonstrated that Byzantine agreement is achievable in polynomial time with message complexity O(n²) for n nodes, provided that fewer than n/3 nodes are faulty.",
  },
];

const FULL_DURATION = 150;

export const DocumentWindow: React.FC = () => {
  const frame = useCurrentFrame();

  // Cursor blink
  const cursorVisible = Math.floor(frame / 16) % 2 === 0;

  // Typing progress — keeps going all the way through, always mid-sentence
  const typingProgress = interpolate(frame, [0, FULL_DURATION], [0.15, 0.95], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const typingText = THESIS_PARAGRAPHS[2].text;
  const visibleChars = Math.floor(typingProgress * typingText.length);
  const displayedTypingText = typingText.slice(0, visibleChars);

  return (
    <div
      style={{
        position: "absolute",
        top: 36,
        left: 120,
        right: 120,
        bottom: 32,
        background: "#1e1e1e",
        borderRadius: 12,
        boxShadow: "0 28px 70px rgba(0,0,0,0.65), 0 0 0 1px rgba(255,255,255,0.07)",
        overflow: "hidden",
        display: "flex",
        flexDirection: "column",
        zIndex: 10,
      }}
    >
      {/* Window title bar */}
      <div
        style={{
          height: 44,
          background: "linear-gradient(180deg, #2c2c2c, #272727)",
          borderBottom: "1px solid rgba(255,255,255,0.07)",
          display: "flex",
          alignItems: "center",
          paddingLeft: 16,
          paddingRight: 20,
          gap: 8,
          flexShrink: 0,
        }}
      >
        {/* Traffic lights — close button shows dot for unsaved */}
        <div style={{ position: "relative", width: 12, height: 12 }}>
          <div style={{ width: 12, height: 12, borderRadius: "50%", background: "#ff5f57", boxShadow: "0 0 0 0.5px rgba(0,0,0,0.25)" }} />
          {/* unsaved dot */}
          <div style={{
            position: "absolute",
            top: "50%",
            left: "50%",
            transform: "translate(-50%, -50%)",
            width: 5,
            height: 5,
            borderRadius: "50%",
            background: "rgba(0,0,0,0.5)",
          }} />
        </div>
        <div style={{ width: 12, height: 12, borderRadius: "50%", background: "#ffbd2e", boxShadow: "0 0 0 0.5px rgba(0,0,0,0.25)" }} />
        <div style={{ width: 12, height: 12, borderRadius: "50%", background: "#28c840", boxShadow: "0 0 0 0.5px rgba(0,0,0,0.25)" }} />

        {/* Title — bullet prefix signals unsaved */}
        <div style={{ flex: 1, textAlign: "center", marginRight: 52 }}>
          <span style={{
            fontFamily: "'SF Pro Text', 'Helvetica Neue', sans-serif",
            fontSize: 13,
            fontWeight: 500,
            color: "rgba(255,255,255,0.55)",
          }}>
            • Chapter_2_Background.docx — Thesis Draft
          </span>
        </div>
      </div>

      {/* Toolbar */}
      <div style={{
        height: 34,
        background: "#252525",
        borderBottom: "1px solid rgba(255,255,255,0.05)",
        display: "flex",
        alignItems: "center",
        paddingLeft: 20,
        gap: 22,
        flexShrink: 0,
      }}>
        {["B", "I", "U"].map((t) => (
          <span key={t} style={{ fontFamily: "'SF Pro Text', sans-serif", fontSize: 13, color: "rgba(255,255,255,0.35)" }}>{t}</span>
        ))}
        <div style={{ width: 1, height: 14, background: "rgba(255,255,255,0.1)" }} />
        <span style={{ fontFamily: "'SF Pro Text', sans-serif", fontSize: 12, color: "rgba(255,255,255,0.3)" }}>Body Text</span>
        <div style={{ width: 1, height: 14, background: "rgba(255,255,255,0.1)" }} />
        <span style={{ fontFamily: "'SF Pro Text', sans-serif", fontSize: 12, color: "rgba(255,255,255,0.3)" }}>12pt</span>
      </div>

      {/* Page area */}
      <div style={{ flex: 1, overflowY: "hidden", display: "flex", justifyContent: "center", background: "#1a1a1a", padding: "28px 0" }}>
        <div
          style={{
            width: 760,
            minHeight: "100%",
            background: "#fafaf8",
            borderRadius: 3,
            boxShadow: "0 4px 24px rgba(0,0,0,0.45)",
            padding: "68px 80px",
            boxSizing: "border-box",
            color: "#1a1a1a",
          }}
        >
          {/* Header */}
          <div style={{ textAlign: "center", marginBottom: 44 }}>
            <div style={{ fontFamily: "'Georgia', serif", fontSize: 12, color: "#666", marginBottom: 8 }}>
              PhD Dissertation — Computer Science Department
            </div>
            <div style={{ fontFamily: "'Georgia', serif", fontSize: 19, fontWeight: 700, lineHeight: 1.35 }}>
              Consensus Under Adversarial Conditions:<br />
              A Framework for Byzantine Fault Analysis
            </div>
            <div style={{ fontFamily: "'Georgia', serif", fontSize: 12, color: "#666", marginTop: 10 }}>
              Chapter 2 of 6
            </div>
          </div>

          {/* Paragraphs */}
          {THESIS_PARAGRAPHS.map((para, i) => (
            <div key={i} style={{ marginBottom: 26 }}>
              <div style={{ fontFamily: "'Georgia', serif", fontSize: 14, fontWeight: 700, marginBottom: 7, color: "#111" }}>
                {para.heading}
              </div>
              <div style={{ fontFamily: "'Georgia', serif", fontSize: 13, lineHeight: 1.78, color: "#222", textAlign: "justify" }}>
                {i === 2 ? (
                  <>
                    {displayedTypingText}
                    <span style={{
                      display: "inline-block",
                      width: 2,
                      height: "1em",
                      background: "#1a6cf5",
                      verticalAlign: "text-bottom",
                      opacity: cursorVisible ? 1 : 0,
                      marginLeft: 1,
                    }} />
                  </>
                ) : (
                  para.text
                )}
              </div>
            </div>
          ))}

          {/* Footer — unsaved warning */}
          <div style={{
            borderTop: "1px solid #e0e0e0",
            paddingTop: 11,
            marginTop: 14,
            fontFamily: "'Helvetica Neue', sans-serif",
            fontSize: 11,
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
          }}>
            <span style={{ color: "#999" }}>Words: 312 / ~12,000 target</span>
            <span style={{
              color: "#c0392b",
              fontWeight: 600,
              display: "flex",
              alignItems: "center",
              gap: 4,
            }}>
              ● Unsaved changes
            </span>
          </div>
        </div>
      </div>
    </div>
  );
};
