---
title: "Conclusion"
section: 7
---

We presented three contributions to pairing-friendly elliptic curve construction:

1. **NTT-friendly Cocks-Pinch.** By constraining the cyclotomic seed $T \equiv 0 \pmod{2^{12}}$, we guarantee two-adicity $\geq 36$ in the scalar field deterministically, while an extended lift search achieves the same for the base field. This exceeds the industry-standard BLS12-381 (two-adicity 32) at a modest increase in generation time (30--60 s vs. 2--10 s).

2. **Readability-aware prime selection.** Our multi-criteria scoring system produces primes that are more amenable to human inspection without any security degradation, addressing the auditability concern in cryptographic parameter generation.

3. **Curve1024.** We instantiate these techniques into a concrete, publicly verifiable curve: $E: y^2 = x^3 + 41$ over a 1024-bit prime field with embedding degree 18, providing 256-bit ECDLP security and NTT support up to length $2^{36}$ in both fields. The complete parameter set (field primes, generator point, CM data) is published and validated by a Rust implementation with 36 passing tests.

The system is suitable for offline signing applications requiring long-term security guarantees and for future pairing-based protocols (BLS aggregate signatures, zk-SNARKs) that benefit from the NTT-friendly field structure.

**Future work** includes: (1) projective/Jacobian coordinates to eliminate per-operation inversions, (2) constant-time Montgomery ladder for side-channel resistance, (3) full optimal Ate pairing implementation over $\mathbb{F}_{p^{18}}$, and (4) extension to other embedding degrees ($k = 12, 24$).

# Availability

The implementation and all curve parameters are available as open-source software under the MIT license [@LumenMath].
