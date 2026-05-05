# Streaming Reservoir Convergence Theorem (SRCT)

A novel mathematical framework for multi-provider adaptive streaming.  
**Zero dependencies** — the core engine runs in any JavaScript runtime with `fetch`.

## The Four Theorems

### Theorem 1: Reservoir Safety Bound
For *k* independent streams with failure rate λ, the probability of
interruption is bounded by Π(1 − e^(-λᵢT)). Expected uptime scales with
the harmonic number Hₖ.

**Result**: A 3-stream reservoir provides **9.15×** the mean time to
depletion of a single stream (Monte Carlo, 5000 trials).

### Theorem 2: Concurrent Acquisition Speedup
Probing *N* providers concurrently vs batched-by-*b* yields speedup
S(N,b) = (N/b) · (1−Fᵇ)/(1−Fᴺ).

**Result**: With 12 providers at 40% failure, concurrent probing is
**4.27× faster** than batching by 3.

### Theorem 3: Reservoir Quality Monotonicity
Under lazy-refill, active stream quality is non-decreasing and converges
to the Pareto frontier of quality × availability.

**Result**: 0 monotonicity violations over 100 simulation steps.

### Theorem 4: Prospect-Weighted Switching
Uses Kahneman–Tversky value functions (α=β=0.88, λ=2.25) with Prelec
probability weighting (γ=0.61) to eliminate thrashing.

**Result**: 1 switch in 100 steps across 5 competing quality levels.

## Quick Start

```ts
import { StreamingReservoir } from "srct";

const reservoir = new StreamingReservoir({ reservoirSize: 3 });

// Phase 1: Sprint — probe all providers concurrently
const candidates = [
  { url: "https://cdn1.example/stream.m3u8", quality: 1080, provider: "cdn1" },
  { url: "https://cdn2.example/stream.m3u8", quality: 720, provider: "cdn2" },
  { url: "https://cdn3.example/stream.m3u8", quality: 480, provider: "cdn3" },
];

const idx = await reservoir.acquire(candidates);
if (idx >= 0) {
  const active = reservoir.getActiveSlot();
  // attachPlayer(active.proxyUrl);
}

// Phase 2: Add newly discovered candidates
await reservoir.refill(moreCandidates);

// Phase 3: Failover on error
player.onError(() => {
  const next = reservoir.failoverActive();
  if (next) attachPlayer(next.proxyUrl);
});
```

## Standalone Functions

```ts
import { prospectValue, probabilityWeight, prospectSwitchScore } from "srct";

// Kahneman–Tversky value function
prospectValue(360);   // gain:  concave
prospectValue(-360);  // loss:  2.25× steeper

// Prelec probability weighting
probabilityWeight(0.01);  // overweighted
probabilityWeight(0.50);  // underweighted

// Full switching score
prospectSwitchScore(720, 1080, 3);  // current, candidate, verifications
```

## Verify

```bash
npx tsx scripts/verify.ts
```

Runs all 22 verification checks. Output:

```
╔══════════════════════════════════════════════════════════════════════════╗
║  Streaming Reservoir Convergence Theorem (SRCT)                         ║
║  Empirical Verification Suite                                           ║
╚══════════════════════════════════════════════════════════════════════════╝

================================================================
  Theorem 1: Reservoir Safety Bound
================================================================
  ✓ Harmonic bound: H₃ = 1 + 1/2 + 1/3 ≈ 1.833
  ...

  Passed: 22/22
  ✓ All 22 verifications passed.
  ✓ SRCT theorems are mathematically valid and empirically verified.
```

## Configuration

| Parameter | Default | Description |
|---|---|---|
| `reservoirSize` | 3 | Number of slots (active + standby) |
| `minSwitchIntervalMs` | 30000 | Minimum time between non-critical switches |
| `minQualityDifference` | 0.4 | Minimum quality gap to justify switch (40%) |
| `healthCheckIntervalMs` | 15000 | Interval between standby health checks |
| `probeTimeoutMs` | 3000 | Timeout per concurrent probe |
| `switchCost` | 0.12 | Prospect theory switch cost |
| `availabilityThreshold` | 0.3 | Minimum availability for reservoir membership |

## Custom Proxy URL Builder

```ts
const reservoir = new StreamingReservoir(
  { reservoirSize: 3 },
  (candidate) => `/my-proxy?url=${encodeURIComponent(candidate.url)}`,
);
```

## Paper

The accompanying paper is published on arXiv: [arXiv:2605.02761](https://arxiv.org/abs/2605.02761).
The paper provides full mathematical proofs, algorithm pseudocode,
TikZ figures, and a comprehensive survey of related work (48 references).

## Citation

```bibtex
@article{agyemang2026srct,
  title={The Streaming Reservoir Convergence Theorem:
         A Prospect-Theoretic Framework for Multi-Provider Adaptive Streaming},
  author={Agyemang, Justice Owusu and Kponyo, Jerry John and
          Agyekum, Kwame Opuni-Boachie Obour and Somuah, Obed Kwasi and
          Amponsah, Elliot and Boakye, Godfred Manu Addo},
  journal={arXiv preprint},
  year={2026},
  note={arXiv:2605.02761},
  url={https://arxiv.org/abs/2605.02761}
}
```

## License

MIT — see [LICENSE](LICENSE).
