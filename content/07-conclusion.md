---
title: "Conclusion"
section: 7
---

We presented two enhancements to the Cocks-Pinch pairing-friendly curve construction. First, by constraining the cyclotomic seed $T \equiv 0 \pmod{2^{12}}$, we guarantee two-adicity $\geq 36$ in the scalar field deterministically, while an extended lift search achieves the same for the base field. This exceeds the industry-standard BLS12-381 (two-adicity 32) at a modest increase in generation time (30--60 s vs. 2--10 s). Second, our readability-aware prime selection scores candidates on eight structural criteria, producing primes that are more amenable to human inspection without any security degradation.

The resulting Curve1024 provides 256-bit ECDLP security with NTT support up to length $2^{36}$ in both fields, validated by a complete Rust implementation with 36 passing tests. The system is suitable for offline signing applications requiring long-term security guarantees.

**Future work** includes: (1) projective/Jacobian coordinates to eliminate per-operation inversions, (2) constant-time Montgomery ladder for side-channel resistance, (3) full optimal Ate pairing implementation over $\mathbb{F}_{p^{18}}$ to enable BLS aggregate signatures, and (4) extension to other embedding degrees ($k = 12, 24$).

# Availability

The implementation is available as open-source software under the MIT license [@LumenMath].
