export {
  StreamingReservoir,
  concurrentProbe,
  prefetchManifest,
  prospectValue,
  probabilityWeight,
  prospectSwitchScore,
  sortCandidatesByQuality,
  defaultProxyUrlBuilder,
  DEFAULT_CONFIG,
} from "./reservoir.js";

export type {
  StreamCandidate,
  ReservoirSlot,
  ReservoirConfig,
  ReservoirState,
  ReservoirEvent,
  ReservoirEventType,
  ReservoirListener,
  ProbeResult,
  ProxyUrlBuilder,
} from "./reservoir.js";
