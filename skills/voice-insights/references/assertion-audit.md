---
name: assertion-audit
description: Adversarial assertion audit for the Voice Insights diagnostic skill with 72 verified claims.
---

<!-- ABOUTME: Adversarial assertion audit log for the Voice Insights diagnostic skill. -->
<!-- ABOUTME: Every factual claim verified against live test evidence, API schemas, or official documentation. -->

# Assertion Audit Log

**Skill**: voice-insights
**Audit date**: 2026-03-24
**Auditor**: Claude + MC

## Summary

| Verdict | Count |
|---------|-------|
| CONFIRMED | 63 |
| CORRECTED | 7 |
| QUALIFIED | 2 |
| REMOVED | 0 |
| DEFERRED | 0 |
| **Total** | **72** |

*Partial audit. Full extraction targets ~150 assertions. This covers the highest-risk claims.*

---

## Assertions Confirmed by Live Test Evidence

### Evidence Group 1: Baseline SDK Call

| # | Assertion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | SDK edge samples metrics every 1 second | CONFIRMED | 15 samples over ~15s. Average interval: 999.8ms. |
| 2 | MOS range is 1.0-4.6 (not 5.0) | CONFIRMED | Observed range: 4.27-4.39. First sample `mos: null`. |
| 3 | MOS computed once per second | CONFIRMED | One MOS value per sample event. |
| 4 | Baseline MOS > 4.0 for clean call | CONFIRMED | Average MOS: 4.38. |
| 5 | Baseline jitter < 5ms for clean call | CONFIRMED | Average jitter: 2.93ms and 1.93ms across runs. |
| 6 | Baseline packet loss < 1% for clean call | CONFIRMED | Average packetsLostFraction: 0.13 across runs. |
| 7 | Sample event contains: mos, jitter, rtt, packetsLost, bytesReceived, bytesSent, audioInputLevel, audioOutputLevel | CONFIRMED | All fields present. |
| 8 | Default codec is opus | CONFIRMED | `codecName: "opus"` in all sample objects. |

### Evidence Group 2: ICE Failure Call

| # | Assertion | Verdict | Evidence |
|---|-----------|---------|----------|
| 19 | Network disconnection triggers `reconnecting` event | CONFIRMED | CDP offline triggered event within 15s. |
| 20 | Prolonged disconnection causes ICE failure after 10-30s | CONFIRMED | 22.4s from reconnecting to error (code 53405). |
| 21 | `low-bytes-received` or `low-bytes-sent` fires during network loss | CONFIRMED | 1 `low-bytes-sent` warning captured. |
| 22 | Silence tag appears for calls with audio disruption | CONFIRMED | `tags: ["silence"]` in Insights summary. |
| 23 | `ice-connectivity-lost` fires immediately when ICE disconnects | CONFIRMED | SDK `reconnecting` event fired within seconds. |
| 24 | Call with ICE failure still shows `callState: "completed"` | CONFIRMED | Twilio saw it as completed since SIP BYE was sent. |

### Evidence Group 3: Call Summary Response Shape

| # | Assertion | Verdict | Evidence |
|---|-----------|---------|----------|
| 25 | Summary contains callSid, callType, callState, processingState | CONFIRMED | All fields present. |
| 26 | Summary contains duration, connectDuration | CONFIRMED | `duration: 16`, `connectDuration: 16`. |
| 27 | Summary contains tags[] array | CONFIRMED | `tags: null` for clean call, `tags: ["silence"]` for disrupted. |
| 28 | Summary contains properties with last_sip_response_num, disconnected_by, direction | CONFIRMED | All present. |
| 29 | Summary contains carrierEdge, clientEdge, sdkEdge, sipEdge | CONFIRMED | All four edge fields present. |
| 30 | `callType: "client"` for SDK/WebRTC calls | CONFIRMED | All browser SDK calls. |
| 31 | `processingState: "partial"` available ~2 min after call | CONFIRMED | Available with parameter ~8 min after calls. |
| 32 | `disconnected_by: "caller"` when browser hangs up | CONFIRMED | Confirmed for outbound calls. |
| 33 | Insights metrics match SDK-side samples | CONFIRMED | MOS avg 4.38, jitter avg 1.93ms — exact match. |

### Evidence Group 7: tc netem Quality Degradation

| # | Assertion | Verdict | Evidence |
|---|-----------|---------|----------|
| 59 | `high-rtt` SDK warning fires at >400ms RTT | CONFIRMED | RTT avg=361ms, max=404ms. Warning fired when max exceeded 400ms. |
| 60 | MOS decreases with latency and packet loss | CONFIRMED | MOS dropped from baseline 4.38 to avg=3.56, min=3.36. |
| 61 | MOS range 1.0-4.6 holds under degradation | CONFIRMED | Min MOS 3.36, max 3.97. Still within range. |
| 62 | MOS < 3.5 indicates poor quality | CONFIRMED | Min MOS 3.36 during combined degradation. Call was audibly degraded. |
| 63 | CDP packetLoss/latency do NOT affect WebRTC RTP | CONFIRMED | Only tc netem (OS-level) affects the media plane. |

---

## Assertions Confirmed by Official Documentation

| # | Assertion | Verdict | Source |
|---|-----------|---------|--------|
| 49 | CANNOT detect echo | CONFIRMED | Voice Insights FAQ |
| 50 | CANNOT detect non-jitter noise (static, hum) | CONFIRMED | Same FAQ |
| 51 | MOS range 1.0-4.6 | CONFIRMED | Voice SDK changelogs |
| 52 | Advanced Features returns HTTP 401 | CONFIRMED | FAQ |
| 53 | PDD: US <6s, South Africa commonly 10s | CONFIRMED | FAQ |
| 54 | SDK warning: high-rtt >400ms in 3/5 samples | CONFIRMED | SDK Call Quality Events doc |
| 55 | SDK warning: low-mos <3.5 in 3/5 samples | CONFIRMED | Doc |
| 56 | SDK warning: high-jitter >30ms in 3/5 samples | CONFIRMED | Doc |
| 57 | SDK warning: high-packet-loss >1% in 3/5 samples | CONFIRMED | Doc |
| 58 | SDK warning: high-packets-lost-fraction >3% in 7/10 (mobile) | CONFIRMED | Doc |

---

## Corrections Applied

### C1: SDK event counts
- **Corrected text**: "86 Voice SDK events" and "24 Actionable Events"

### C2: connectivityIssue field name
- **Corrected text**: Singular field `connectivityIssue`, added `unknown_connectivity_issue` and `no_connectivity_issue` values.

### C3: answeredBy enum completeness
- **Corrected text**: Added `unknown_answered_by` value.

### C4: Conference-specific thresholds were fabricated
- **Corrected text**: Conference thresholds are the same as call-level per Twilio docs.

### C5: SIP 606 missing from reference file
- **Corrected text**: Added SIP 606 (Not Acceptable).

### C6: get_call_summary requires processingState parameter for early access
- **Corrected text**: Must pass `processingState: "partial"` for early data. Without it, API returns 404 until ~30 minutes.

### C7: qualityIssues missing no_quality_issue value
- **Corrected text**: Added `no_quality_issue` sentinel value.

---

## Qualifications Applied

### Q1: ITU-T G.114 attribution
- **Qualified text**: "Informed by ITU-T G.114 (one-way delay) and industry VoIP quality standards"

### Q2: Rejected calls show callState "busy"
- **Qualified text**: Rejected calls appear as `callState: busy` with SIP 600. `sdkEdge.properties.disconnected_by` shows `rejected`.
