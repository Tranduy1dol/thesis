---
title: "Implementation and Evaluation"
section: 5
---

# Implementation Overview

We implement the complete system in Rust without external cryptographic dependencies. The implementation comprises:

- A custom `U1024` big integer type with Montgomery multiplication [@Montgomery1985]
- Prime field arithmetic (`PrimeFieldElement`) with constant-time Fermat inversion
- Elliptic curve group operations in affine coordinates
- Schnorr and ECDSA signature schemes
- The parameter generation tool (Algorithm 1 + readability scoring)

The test suite contains 36 tests covering arithmetic correctness, group law verification, and attack simulation (MOV, Anomalous, Invalid Curve).

# Generated Parameters

The construction produces the following curve (Curve1024):

- Curve equation: $E: y^2 = x^3 + 41$
- Base field: $p \approx 2^{1024}$, $\nu_2(p-1) = 36$
- Scalar field: $r \approx 2^{512}$, $\nu_2(r-1) = 36$
- Embedding degree: $k = 18$
- CM discriminant: $D = -3$
- $\rho = \log p / \log r = 2.0$

# Performance Benchmarks

The following table reports timing measurements using the Criterion framework (release build, LLVM O3 optimization, 10 samples per measurement).

| Operation | Min | Mean | Max |
|-----------|-----|------|-----|
| Key generation | 1.629 s | 1.687 s | 1.757 s |
| Schnorr sign | 1.473 s | 1.551 s | 1.641 s |
| Schnorr verify | 2.656 s | 2.831 s | 3.025 s |
| ECDSA sign | 1.524 s | 1.606 s | 1.711 s |
| ECDSA verify | 2.847 s | 3.140 s | 3.459 s |
| Scalar mult. $[k]G$ | 1.061 s | ~1.2 s | 1.489 s |

: Performance Benchmarks (no AVX-512)

The performance reflects the 1024-bit field size: each scalar multiplication requires ~512 double-and-add iterations, each involving a Fermat inversion (~1536 Montgomery multiplications). This is approximately $8000\times$ slower than optimized secp256k1 implementations, which is expected given the $4\times$ larger field and $O(n^2)$ multiplication cost. The system targets offline signing scenarios (legal documents, software releases, PKI certificates) where seconds of latency are acceptable.

# Security Analysis

| Attack | Complexity | Status |
|--------|-----------|--------|
| Pollard-$\rho$ (ECDLP) | $O(2^{256})$ | Secure |
| MOV reduction | DLP in $\mathbb{F}_{p^{18}}$ (18432-bit) | Secure |
| Anomalous (SSSA) | Requires $\#E = p$ | Immune |
| TNFS | $\geq 250$-bit in $\mathbb{F}_{p^{18}}$ | Secure |
| Invalid curve | Point validation in constructor | Mitigated |

: Security Evaluation Summary

The 256-bit ECDLP security exceeds NIST SP 800-57 recommendations through 2030+ [@NIST80057]. The MOV attack maps ECDLP to DLP in $\mathbb{F}_{p^{18}}$, a field of 18,432 bits---far exceeding the 3,072-bit threshold for 128-bit security. The curve is provably non-anomalous since $\#E(\mathbb{F}_p) = h \cdot r$ with $r \approx 2^{512} \neq p \approx 2^{1024}$.

**Limitation:** The current affine-coordinate implementation uses variable-time double-and-add, which leaks scalar bits through timing. A Montgomery ladder (constant-time) is identified as future work.

# Curve Family Comparison

| Curve | $|p|$ | $\rho$ | $\nu_2$ | Security |
|-------|--------|--------|---------|----------|
| BN254 | 254 | 1.0 | ~1 | 100-bit |
| BLS12-381 | 381 | 1.5 | 32 | 128-bit |
| KSS18 (generic) | varies | 1.33 | random | varies |
| **Curve1024** | 1024 | 2.0 | **36** | **256-bit** |

: Comparison with Standard Curve Families
