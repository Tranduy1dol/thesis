---
title: "Introduction"
section: 1
---

Pairing-friendly elliptic curves underpin a growing class of cryptographic protocols, from BLS aggregate signatures [@BLS2001] to succinct non-interactive zero-knowledge proofs (zk-SNARKs) [@Groth2016; @PLONK2019]. These protocols require curves whose scalar field and base field support efficient polynomial arithmetic via the Number Theoretic Transform (NTT), which in turn demands that both field primes satisfy $q \equiv 1 \pmod{2^s}$ for a sufficiently large $s$.

The Cocks-Pinch method [@CocksPinch2001] offers unmatched flexibility in constructing pairing-friendly curves with arbitrary embedding degrees. Unlike parametric families such as BN [@FreemanScottTeske2010] or BLS12 [@BLS12_381], the Cocks-Pinch approach can target specific security levels and field sizes. However, the traditional algorithm treats NTT-friendliness as an afterthought---primes are generated with random two-adicity, typically only 1--3 bits, rendering them unsuitable for modern proof systems.

A separate but related concern is *parameter auditability*. The Dual_EC_DRBG incident [@DualECDRBG] demonstrated that opaque cryptographic constants can conceal backdoors. While the Cocks-Pinch method is inherently transparent (all parameters derive from a public seed), the resulting primes are typically inscrutable hexadecimal blobs that resist manual inspection.

**Contributions.** This paper presents three results:

1. **Improved Cocks-Pinch with NTT constraints.** We modify the Cocks-Pinch construction to *guarantee* high two-adicity in both field primes by constraining the cyclotomic seed $T$. Choosing $T \equiv 0 \pmod{2^{12}}$ yields $\nu_2(r-1) \geq 36$ deterministically, while an extended lift search ensures $\nu_2(p-1) \geq 36$. The resulting two-adicity of 36 exceeds BLS12-381's value of 32.

2. **Readability-aware prime selection.** We introduce a multi-criteria scoring system that evaluates candidate primes on eight structural properties (binary sparseness, zero limbs, hex density, etc.) and selects the most human-auditable parameters without sacrificing security.

3. **Curve1024: a concrete 1024-bit pairing-friendly curve.** We instantiate the above techniques to produce a complete, publicly verifiable curve with embedding degree $k=18$, scalar field order $r \approx 2^{512}$ (256-bit ECDLP security), and equation $E: y^2 = x^3 + 41$. The full parameter set---including generator point---is published and validated by a Rust implementation with 36 passing tests.

**Organization.** Section 2 reviews background on pairing-friendly curves and the CM method. Section 3 presents our NTT-friendly Cocks-Pinch modification. Section 4 describes the readability scoring system. Section 5 presents the Curve1024 parameters and evaluates the implementation. Section 6 discusses related work, and Section 7 concludes.
