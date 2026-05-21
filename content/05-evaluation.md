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
| 15 | `0x0000000000000000` | zero |
| 14 | `0x0000000000000000` | zero |
| 13 | `0x0000000000000000` | zero |
| 12 | `0x0000000000000000` | zero |
| 11 | `0x0000000000000000` | zero |
| 10 | `0x0000000000000000` | zero |
| 9 | `0x0000000000000000` | zero |
| 8 | `0x0000000000000000` | zero |
| 7 | `0xc042c3389e72044d` | |
| 6 | `0x9ec8078aea7bc954` | |
| 5 | `0xebf209d918f0ef27` | |
| 4 | `0x425259e247711927` | |
| 3 | `0x97463bf23832d0de` | |
| 2 | `0x5e46e47fc61cab50` | |
| 1 | `0x4bcfd36fc2a945c5` | |
| 0 | `0x1055d97000000001` | tail: $d \cdot 2^{36} + 1$ |

: Scalar field prime $r$ — 64-bit limbs, hex, MSB first

**Key readability features:** 8 of 16 limbs are zero (50%), and the final limb visually confirms the NTT-friendly structure with the `00000001` suffix (36 trailing zero bits before the $+1$).

## Base Field Prime (1024 bits)

The base field prime $p = (t^2 + 3y^2)/4$ decomposes as:

$$p = d_p \cdot 2^{36} + 1$$

where $d_p$ is a 988-bit odd integer. The final limb shares the same tail pattern as $r$:

| Limb | Value | Note |
|------|-------|------|
| 15 | `0xc0859da83a500988` | |
| 14 | `0x10eea35c61fea054` | |
| 13 | `0xc866902599220d30` | |
| 12 | `0xc93f38265ed6b830` | |
| 11 | `0x5785b8a073e482e8` | |
| 10 | `0x685cfeeb388dc45e` | |
| 9 | `0xbca1686245b326fe` | |
| 8 | `0x824ca74ac0844160` | |
| 7 | `0xf4e289806084e50e` | |
| 6 | `0x6c02f32cb94d786b` | |
| 5 | `0xf80fb080c07d6a07` | |
| 4 | `0x73f2b4591eb70df3` | |
| 3 | `0x9367aa32ebb42449` | |
| 2 | `0xe0a648f61a20e876` | |
| 1 | `0xf971f3bf976a7d6a` | |
| 0 | `0xdd20d97000000001` | tail: $d \cdot 2^{36} + 1$ |

: Base field prime $p$ — 64-bit limbs, hex, MSB first

**Shared structure:** The lowest limb of both primes ends with `0x...d97000000001`, encoding the factor $d \cdot 2^{36} + 1$. This is a direct algebraic consequence of the seed constraint $T \equiv 0 \pmod{2^{12}}$ (Lemma 1), not a coincidence — any auditor can independently verify it by recomputing $\Phi_{18}(T) \bmod 2^{36}$.

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

A generator point $G = (G_x, G_y)$ of prime order $r$ is obtained by cofactor multiplication of a random curve point. The full coordinates are published in the project repository [@Curve1024Impl].

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

We implement the complete system in Rust without external cryptographic dependencies [@Curve1024Impl]. The implementation comprises:

- A custom `U1024` big integer type with Montgomery multiplication [@Montgomery1985]
- Prime field arithmetic (`PrimeFieldElement`) with constant-time Fermat inversion
- Elliptic curve group operations in both affine and projective (Jacobian) coordinates
- Constant-time Montgomery ladder for scalar multiplication, using the `subtle` crate for branch-free conditional swaps
- Schnorr and ECDSA signature schemes
- The parameter generation tool (improved Cocks-Pinch + readability scoring)

The test suite contains 36 tests covering arithmetic correctness, group law verification, and attack simulation (MOV, Anomalous, Invalid Curve).

# Performance Benchmarks

| Operation | Min | Mean | Max |
|-----------|-----|------|-----|
| Key generation | 12.5 ms | 13.0 ms | 13.8 ms |
| Schnorr sign | 13.6 ms | 14.3 ms | 15.1 ms |
| Schnorr verify | 26.8 ms | 27.9 ms | 29.4 ms |
| ECDSA sign | 14.2 ms | 14.9 ms | 15.7 ms |
| ECDSA verify | 29.1 ms | 30.4 ms | 32.0 ms |

: Performance benchmarks ($n = 100$ iterations, Criterion, release build, LLVM O3, projective coordinates with Montgomery ladder). Machine: Intel Core i7-1260P, 16 GB RAM, Arch Linux 7.0.5.

The projective coordinate representation with Montgomery ladder yields approximately $100\times$ improvement over the naive affine implementation (which required a Fermat inversion per doubling step). Each scalar multiplication now performs ~512 projective doublings and conditional additions, with a single affine conversion at the end. The resulting performance---14 ms for signing, 28 ms for verification---is practical for interactive applications, not merely offline scenarios. Verification is approximately $2\times$ slower than signing because ECDSA/Schnorr verification requires two independent scalar multiplications ($u_1 G + u_2 Q$).

# Security Analysis

```{=latex}
\begin{table}[t]
\centering
\caption{Security evaluation summary}
\label{tab:security}
\scriptsize
\begin{tabular}{lll}
\toprule
Attack & Complexity & Status \\
\midrule
Pollard-$\rho$ (ECDLP) & $O(2^{256})$ & Secure \\
MOV reduction & DLP in $\mathbb{F}_{p^{18}}$ (18432-bit) & Secure \\
Anomalous (SSSA) & Requires $\#E = p$ & Immune \\
TNFS \cite{BarbulescuDuquesne2019} & $\geq 250$-bit in $\mathbb{F}_{p^{18}}$ & Secure \\
Invalid curve & Point validation & Mitigated \\
\bottomrule
\end{tabular}
\end{table}
```

The 256-bit ECDLP security exceeds NIST SP 800-57 recommendations through 2030+ [@NIST80057]. The MOV attack [@MOV1993] maps ECDLP to DLP in $\mathbb{F}_{p^{18}}$, a field of 18,432 bits---far exceeding the 3,072-bit threshold for 128-bit security. The curve is provably non-anomalous [@SmartAnomaly1999] since $\#E(\mathbb{F}_p) = h \cdot r$ with $r \approx 2^{512} \neq p \approx 2^{1024}$.

**TNFS resistance.** The complexity of DLP in $\mathbb{F}_{p^{18}}$ via the Tower Number Field Sieve is $L_{p^{18}}[1/3, c]$ where $c \approx (128/9)^{1/3} \approx 2.42$ for the most favorable variant [@KimBarbulescu2016]. For an 18,432-bit field, this yields an estimated work factor exceeding $2^{250}$ operations [@BarbulescuDuquesne2019], well above the 128-bit security threshold.

**Subgroup security.** The curve order is $\#E(\mathbb{F}_p) = h \cdot r$ with cofactor $h \approx 2^{512}$. Points received from untrusted sources must be validated: (1) verify the point lies on the curve ($y^2 = x^3 + 41$), and (2) multiply by the cofactor $h$ to project into the prime-order subgroup, or equivalently verify $[r]P = \mathcal{O}$. The implementation performs curve membership checks in the point constructor.

**Twist security.** Since $j = 0$ (CM discriminant $D = -3$), the curve admits six sextic twists $E_d: y^2 = x^3 + d$ for $d \in \{41\zeta^i : i = 0, \ldots, 5\}$ where $\zeta$ is a primitive 6th root of unity in $\mathbb{F}_p$. Twist security is relevant for implementations using point compression, where an invalid $x$-coordinate may land on a twist rather than the curve. Full twist-order factorization is deferred to future work; the current implementation validates all points explicitly.

**Side-channel resistance.** Scalar multiplication uses a constant-time Montgomery ladder over projective coordinates, with conditional point swaps implemented via the `subtle` crate's `conditional_swap` (bitwise masking, no branches). This eliminates timing leakage of scalar bits. The projective representation also removes per-step field inversions, requiring only a single inversion at the final affine conversion.

# Curve Family Comparison

```{=latex}
\begin{table}[t]
\centering
\caption{Comparison with standard pairing-friendly curve families}
\label{tab:comparison}
\scriptsize
\begin{tabular}{lcccc}
\toprule
Curve & $|p|$ & $\rho$ & $\nu_2$ & Security \\
\midrule
BN254 & 254 & 1.0 & $\sim$1 & 100-bit \\
BLS12-381 & 381 & 1.5 & 32 & 128-bit \\
KSS18 & varies & 1.33 & instance-dep. & varies \\
\textbf{Curve1024} & \textbf{1024} & 2.0 & \textbf{36} & \textbf{256-bit} \\
\bottomrule
\end{tabular}
\end{table}
```

Among the curves compared in `\tablename~\ref{tab:comparison}`{=latex}, Curve1024 provides the highest ECDLP security level (256-bit) and the highest two-adicity (36), at the cost of a larger $\rho$-value inherent to the Cocks-Pinch method. The 18,432-bit pairing target field provides substantial margin against TNFS attacks. `\figurename~\ref{fig:comparison}`{=latex} visualizes this tradeoff.

```{=latex}
\input{figures/curve-comparison}
```
