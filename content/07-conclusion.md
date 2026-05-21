---
title: "Conclusion"
section: 7
---

We presented three contributions to pairing-friendly elliptic curve construction:

1. **NTT-friendly Cocks-Pinch.** By constraining the cyclotomic seed $T \equiv 0 \pmod{2^{12}}$, we guarantee two-adicity $\geq 36$ in the scalar field deterministically, while an extended lift search achieves the same for the base field. For comparison, BLS12-381 achieves two-adicity 32 within the BLS12 family; our construction obtains 36 via the Cocks-Pinch method at a different tradeoff point ($\rho = 2.0$ vs. 1.5) and a modest increase in generation time (30--60 s vs. 2--10 s).

2. **Readability-aware prime selection.** Our multi-criteria scoring system produces primes that are more amenable to human inspection without any security degradation, addressing the auditability concern in cryptographic parameter generation.

3. **Curve1024.** We instantiate these techniques into a concrete, publicly verifiable curve: $E: y^2 = x^3 + 41$ over a 1024-bit prime field with embedding degree 18, providing 256-bit ECDLP security and NTT support up to length $2^{36}$ in both fields. The complete parameter set (field primes, generator point, CM data) is published alongside a Rust implementation with constant-time scalar multiplication (Montgomery ladder over projective coordinates) and a test suite verifying correctness and attack resistance.

The system is suitable for applications requiring long-term security guarantees---including interactive signing (14 ms per signature) and future pairing-based protocols (BLS aggregate signatures, zk-SNARKs) that benefit from the NTT-friendly field structure.

**Future work** includes: (1) full optimal Ate pairing implementation over $\mathbb{F}_{p^{18}}$, enabling BLS aggregate signatures and zk-SNARK verification directly on Curve1024, and (2) extension to other embedding degrees ($k = 12, 24$) to explore the tradeoff between pairing target size and field element compactness.

# Availability

The implementation, parameter generation tool, and test suite are publicly available at \url{https://github.com/Tranduy1dol/curve1024} (tag \texttt{v1.5.0-alpha}) under the MIT license. All curve parameters can be independently reproduced from the seed $T$ using the provided construction example.
