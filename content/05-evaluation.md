---
title: "Curve1024: Parameters and Evaluation"
section: 5
---

This section presents the concrete Curve1024 parameters produced by our improved Cocks-Pinch construction with readability-aware selection, followed by implementation details and security analysis.

# Curve1024 Parameters

The construction produces the following pairing-friendly elliptic curve over a 1024-bit prime field. All parameters are publicly verifiable from the seed $T$.

## Seed and Construction

The curve is fully determined by a single 86-bit seed:

$$T = \texttt{0x26704d2ace0facdd539} \cdot 2^{12}$$

This seed satisfies $T \equiv 0 \pmod{2^{12}}$, guaranteeing $\nu_2(r-1) = 36$ via the factorization $r - 1 = T^3(T^3 - 1)$.

## Scalar Field Order (512 bits)

The scalar field prime $r = \Phi_{18}(T) = T^6 - T^3 + 1$ decomposes as:

$$r = d_r \cdot 2^{36} + 1$$

where $d_r$ is a 476-bit odd integer. In 64-bit limb representation (MSB first):

| Limb | Value | Note |
|------|-------|------|
| 15 | `0000000000000000` | zero |
| 14 | `0000000000000000` | zero |
| 13 | `0000000000000000` | zero |
| 12 | `0000000000000000` | zero |
| 11 | `0000000000000000` | zero |
| 10 | `0000000000000000` | zero |
| 9 | `0000000000000000` | zero |
| 8 | `0000000000000000` | zero |
| 7 | `c042c3389e72044d` | |
| 6 | `9ec8078aea7bc954` | |
| 5 | `ebf209d918f0ef27` | |
| 4 | `425259e247711927` | |
| 3 | `97463bf23832d0de` | |
| 2 | `5e46e47fc61cab50` | |
| 1 | `4bcfd36fc2a945c5` | |
| 0 | `1055d97000000001` | tail: $d \cdot 2^{36} + 1$ |

: Scalar field prime $r$ — limb decomposition

**Key readability features:** 8 of 16 limbs are zero (50%), and the final limb visually confirms the NTT-friendly structure with the `00000001` suffix (36 trailing zero bits before the $+1$).

## Base Field Prime (1024 bits)

The base field prime $p = (t^2 + 3y^2)/4$ decomposes as:

$$p = d_p \cdot 2^{36} + 1$$

where $d_p$ is a 988-bit odd integer. The final limb shares the same tail pattern as $r$:

| Limb | Value | Note |
|------|-------|------|
| 15 | `c0859da83a500988` | |
| 14 | `10eea35c61fea054` | |
| 13 | `c866902599220d30` | |
| 12 | `c93f38265ed6b830` | |
| 11 | `5785b8a073e482e8` | |
| 10 | `685cfeeb388dc45e` | |
| 9 | `bca1686245b326fe` | |
| 8 | `824ca74ac0844160` | |
| 7 | `f4e289806084e50e` | |
| 6 | `6c02f32cb94d786b` | |
| 5 | `f80fb080c07d6a07` | |
| 4 | `73f2b4591eb70df3` | |
| 3 | `9367aa32ebb42449` | |
| 2 | `e0a648f61a20e876` | |
| 1 | `f971f3bf976a7d6a` | |
| 0 | `dd20d97000000001` | tail: $d \cdot 2^{36} + 1$ |

: Base field prime $p$ — limb decomposition

**Shared tail pattern:** Both $p$ and $r$ end with `...d970_00000001`, a direct consequence of the seed constraint propagating through the construction. This visual consistency aids manual verification.

## Curve Summary

| Parameter | Value |
|-----------|-------|
| Equation | $E: y^2 = x^3 + 41$ |
| Base field $|p|$ | 1024 bits |
| Scalar field $|r|$ | 512 bits |
| Embedding degree $k$ | 18 |
| CM discriminant $D$ | $-3$ (hence $j = 0$) |
| $\rho = \log p / \log r$ | 2.0 |
| $\nu_2(p-1)$ | 36 |
| $\nu_2(r-1)$ | 36 |
| Cofactor $h = \#E/r$ | $\approx 2^{512}$ |

: Curve1024 parameters

The curve equation $y^2 = x^3 + 41$ arises from the CM method with $D = -3$: the Hilbert class polynomial $H_{-3}(x) = x$ gives $j = 0$, yielding the family $y^2 = x^3 + b$. The twist $b = 41$ is selected by verifying which of the six sextic twists has group order divisible by $r$.

A generator point $G = (G_x, G_y)$ of prime order $r$ is obtained by cofactor multiplication of a random curve point. The full coordinates are published in the project repository [@LumenMath].

## Readability Metrics

| Metric | $p$ (1024-bit) | $r$ (512-bit) |
|--------|----------------|---------------|
| Hamming weight | 464/1024 (45%) | 235/512 (46%) |
| Two-adicity | 36 | 36 |
| Zero 64-bit limbs | 0/16 | 8/16 (50%) |
| Hex zero digits | 33/256 (13%) | 16/128 (12.5%) |
| Trailing zero bits | 36 | 36 |

: Readability comparison

The scalar field prime $r$ is notably sparse: half its limb representation is zero, making it easy to recognize and verify in debugging output. Both primes exceed BLS12-381's two-adicity of 32.

# Implementation

We implement the complete system in Rust without external cryptographic dependencies [@LumenMath]. The implementation comprises:

- A custom `U1024` big integer type with Montgomery multiplication [@Montgomery1985]
- Prime field arithmetic (`PrimeFieldElement`) with constant-time Fermat inversion
- Elliptic curve group operations in affine coordinates
- Schnorr and ECDSA signature schemes
- The parameter generation tool (improved Cocks-Pinch + readability scoring)

The test suite contains 36 tests covering arithmetic correctness, group law verification, and attack simulation (MOV, Anomalous, Invalid Curve).

# Performance Benchmarks

| Operation | Min | Mean | Max |
|-----------|-----|------|-----|
| Key generation | 1.629 s | 1.687 s | 1.757 s |
| Schnorr sign | 1.473 s | 1.551 s | 1.641 s |
| Schnorr verify | 2.656 s | 2.831 s | 3.025 s |
| ECDSA sign | 1.524 s | 1.606 s | 1.711 s |
| ECDSA verify | 2.847 s | 3.140 s | 3.459 s |
| Scalar mult. $[k]G$ | 1.061 s | ~1.2 s | 1.489 s |

: Performance benchmarks (Criterion, release build, LLVM O3, no AVX-512)

The performance reflects the 1024-bit field size: each scalar multiplication requires ~512 double-and-add iterations, each involving a Fermat inversion (~1536 Montgomery multiplications). This is approximately $8000\times$ slower than optimized secp256k1 implementations, which is expected given the $4\times$ larger field and $O(n^2)$ multiplication cost. The system targets offline signing scenarios (legal documents, software releases, PKI certificates) where seconds of latency are acceptable.

# Security Analysis

| Attack | Complexity | Status |
|--------|-----------|--------|
| Pollard-$\rho$ (ECDLP) | $O(2^{256})$ | Secure |
| MOV reduction | DLP in $\mathbb{F}_{p^{18}}$ (18432-bit) | Secure |
| Anomalous (SSSA) | Requires $\#E = p$ | Immune |
| TNFS [@BarbulescuDuquesne2019] | $\geq 250$-bit in $\mathbb{F}_{p^{18}}$ | Secure |
| Invalid curve | Point validation in constructor | Mitigated |

: Security evaluation summary

The 256-bit ECDLP security exceeds NIST SP 800-57 recommendations through 2030+ [@NIST80057]. The MOV attack [@MOV1993] maps ECDLP to DLP in $\mathbb{F}_{p^{18}}$, a field of 18,432 bits---far exceeding the 3,072-bit threshold for 128-bit security. The curve is provably non-anomalous [@SmartAnomaly1999] since $\#E(\mathbb{F}_p) = h \cdot r$ with $r \approx 2^{512} \neq p \approx 2^{1024}$.

**Limitation:** The current affine-coordinate implementation uses variable-time double-and-add, which leaks scalar bits through timing. A Montgomery ladder (constant-time) is identified as future work.

# Curve Family Comparison

| Curve | $|p|$ (bits) | $\rho$ | $\nu_2$ | ECDLP Security | Pairing Target |
|-------|--------|--------|---------|----------|---------|
| BN254 | 254 | 1.0 | ~1 | 100-bit | 3048-bit |
| BLS12-381 | 381 | 1.5 | 32 | 128-bit | 4572-bit |
| KSS18 (generic) | varies | 1.33 | random | varies | varies |
| **Curve1024** | **1024** | 2.0 | **36** | **256-bit** | **18432-bit** |

: Comparison with standard pairing-friendly curve families

Curve1024 occupies a unique position: it provides the highest ECDLP security level (256-bit) and the highest two-adicity (36) among deployed pairing-friendly curves, at the cost of a larger $\rho$-value inherent to the Cocks-Pinch method. The 18,432-bit pairing target field provides substantial margin against TNFS attacks.
