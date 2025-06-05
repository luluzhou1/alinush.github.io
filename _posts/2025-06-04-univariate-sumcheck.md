---
tags:
title: Univariate sumcheck
#date: 2020-11-05 20:45:59
#published: false
permalink: univariate-sumcheck
sidebar:
    nav: cryptomat
#article_header:
#  type: cover
#  image:
#    src: /pictures/.jpg
---

{: .info}
**tl;dr:** Who said you can only sumcheck your multivariate polynomials? $\sum_{i\in[n]} a(\omega^i)b(\omega^i)$ can be proved with two size-$n$ multiexps and 6 FFTs! And verified with a size-4 multipairing (and a bit more?).

<!--more-->

<!-- Here you can define LaTeX macros -->
<div style="display: none;">$
$</div> <!-- $ -->

## Introduction

Originally introduced by Ben-Sasson et al. in Aurora[^BCRplus19].
(Interestingly, they introduce two kinds of sumchecks, IIUC, not just over multiplicative subgroups like $\omega^i$ roots of unity but also additive cosets / affine subspaces of $\F$.)

Useful for many things: silent-setup threshold signatures[^DCXplus23e], zkSNARKs[^BCRplus19]$^,$[^RZ21]$^,$[^LSZ22e], lookup arguments[^ZGKplus22e], etc.

{: .note}
In this blog, we describe the sumcheck protcols as polynomial interactive oracle proofs (PIOPs) and often reason about instantiating them using [KZG](/kzg) polynomial commitments.

## Related work

A new paper proposes a more efficient univariate sumcheck[^ZSG24e].

{: .todo}
Analyze!

## Sumcheck for $\sum_i p(\omega^i)$

Recall the definition of a degree-$(n-1)$ [Lagrange polynomial](/lagrange-interpolation) when the evaluation domain is $\mathbb{H} = \\{\omega^0,\ldots,\omega^{n-1}\\}$: i.e., the set of all $n$th roots of unity.
\begin{align}
\lagr_i(X) = \frac{\omega^i(X^n - 1)}{n(X-\omega^i)}
\end{align}
A key observation is: 
\begin{align}
\lagr_i(0) = \frac{\omega^i(0^n - 1)}{n(0-\omega^i} = \frac{\omega^i (-1)}{n(-\omega^i)} = n^{-1}
\end{align}
Next, given a degree-$(n-1)$ polynomial $p(X)$, we can write it as: 
\begin{align}
p(X) &= \sum_{i\in[n]} \lagr_i(X)p(\omega^i)\Rightarrow
\end{align}
As a result, evaluation $p(X)$ at $X=0$, we get:
\begin{align}
p(0) &= \sum_{i\in[n]}\lagr_i(0) p(\omega^i) = n^{-1} \sum_{i\in[n]} p(\omega^i)\Rightarrow \greenbox{\sum_{i\in[n]} p(\omega^i) = n\cdot p(0)}
\end{align}
Therefore, for any polynomial $p(X)$, a sumcheck proof over $\mathbb{H}$ would consist of:
1. A degree-bound check on $p(X)$: i.e., is $\deg{p} < n$?
2. An evaluation proof for $p(0)$

This is great, but typically, it is not very useful to do a sumcheck on a single polynomial $p(X)$.
It is often need to do sumchecks on products of polynomials.
We address this next.

{: .note}
**A KZG degree proof:**
Let $d = \deg{p}$ and let $p_1$ denote its KZG commitment.
Let $q$ be the **max** size of the powers-of-tau. (There should be no more than this!)
Compute $P(X) = p(X) \cdot X^{q - d}$ and commit to it as $P_1$.
Check that $e(P_1, g_2) \equals e(p_1, g_2^{\tau^{q - d}})$.
**Disadvantages**: Assumes $q-d$ powers of tau in $\Gr_2$.
Commits to a degree-$q$ polynomial $P$? (But it's shifted, so there should only be $O(d)$ work?)


## Sumcheck for $\sum_i a(\omega^i)b(\omega^i)$

We first describe a _naive_ protocol and then the actual optimized one.

### Naive protocol

First, interpolate degree-$(n-1)$ (not $2n-1$!) polynomial $c(X)$ such that:
\begin{align}
\label{eq:c}
c(\omega^i) \bydef a(\omega^i)b(\omega^i)
\end{align}

Second, compute a quotient $q(X)$ arguing that $c(X)$ agrees with $a$ and $b$ over $\mathbb{H}$:
\begin{align}
a(X)b(X) - c(X) &= q(X) (X^n - 1)\\\\\
\label{eq:product-sum}
a(X)b(X) &= c(X) + q(X) (X^n - 1)
\end{align}

We know [from above](#sumcheck-for-sum_i-pomegai) that:
\begin{align}
\sum_{i\in[n]} c(\omega^i) &= n \cdot c(0)
\end{align}
Thus, we know that the sum we are interested in is:
\begin{align}
S\bydef \sum_{i\in[n]} a(\omega^i)b(\omega^i) =\sum_{i\in[n]} c(\omega^i) = n\cdot c(0)
\end{align}


Assuming KZG commitments for max-degree-$M$ polynomials (with $M\ge n-1$), we could stop here and say that the sumcheck proof would:
 1. An evaluation proof $\pi_0$ for $c(0)$
 2. A commitment $C_1$ to $c(X)$
 4. A degree proof $(d,\pi_D)$ for $C_1$, vouching that $\deg{c} = d < n$
 3. A commitment $Q_1$ to $q(X)$

Assuming we already have commitments $A_1$ and $B_2$ to $a(X)$ and $b(X)$, respectively, verification would involve:
\begin{align}
e\left(C_1, g_2^{-c(0)}\right) &\equals e\left(\pi_0, g_2^{\tau - 0}\right)\\\\\
e(A_1, B_2) &\equals e(C_1, g_2) e\left(Q_1, g_2^{\tau^n - 1}\right)\\\\\
e\left(C_1, g_2^{\tau^{M - d}}\right) &\equals e(\pi_D, g_2)\\\\\
d &\stackrel{?}{<} n
\end{align}

**tl;dr**: Unfortunately, even after combining this into a multi-pairing, this is a bit expensive (prover time, verifier time and proof size). 

### Optimized protocol

Recall that $c(X)$ is interpolated so as to agree with $a(X)$ and $b(X)$ on $\mathbb{H}$ as per Equation \ref{eq:c}.
This way, $\sum_{i\in[n]} a(\omega^i)b(\omega^i) = \sum_i c(\omega^i) = n\cdot c(0)\bydef S$, as [explained before](#sumcheck-for-sum_i-pomegai).

This way, Equation \ref{eq:product-sum}, restated below, holds:
\begin{align}
a(X)b(X) &= q(X) (X^n - 1) + c(X)
\end{align}

To do better than the naive protocol, observe that, by the [polynomial remainder theorem](/polynomials#the-polynomial-remainder-theorem), there exists a quotient polynomial $r(X)$ such that $c(X) - c(0) = r(X)X$ and rewrite Equation \ref{eq:product-sum} above as:
\begin{align}
a(X)b(X) &= q(X) (X^n - 1) + c(X)\\\\\
a(X)b(X) &= q(X) (X^n - 1) + r(X)X + c(0)\\\\\
\label{eq:univariate-sumcheck}
a(X)b(X) &= q(X) (X^n - 1) + r(X)X + n^{-1}S
\end{align}
Then, the **optimized sumcheck proof** is 2 $\Gr_1$ and 1 $\Gr_2$ group element (e.g., 192 bytes on [BLS12-381](/pairings#bls12-381-performance)):
 1. KZG commitment $Q_1$ to $q(X)$
 1. KZG commitment $R_1$ to $r(X)$
 4. A degree proof $(d,\pi_D)$ for $R_1$, vouching that $\deg{r} = d < n - 1$

To verify this proof:
\begin{align}
e(A_1, B_2) &\equals e(Q_1, g_2^{\tau^n - 1})  e(R_1, g_2^\tau) e(g_1^{n^{-1}S}, g_2)\\\\\
e\left(R_1, g_2^{\tau^{M - d}}\right) &\equals e(\pi_D, g_2)\\\\\
d &\stackrel{?}{<} n-1
\end{align}

### Verifier time ($\approx$ 1.2 ms)

The two pairing equations in the verifier can be combined into one by picking a random scalar $\alpha\in\F$ (e.g., via Fiat-Shamir[^FS87]) and only checking:
\begin{align}
e(A_1, B_2) &\equals e(Q_1, g_2^{\tau^n - 1})  e\left(R_1, (g_2^\tau)^\alpha \cdot g_2^{\tau^{M - d}}\right) e(g_1^{n^{-1}S}\cdot \pi_D^\alpha, g_2)\\\\\
d &\stackrel{?}{<} n-1
\end{align}

So, the verifier time is:
1. 1 group operation in $\Gr_2$ (for RHS in pairing #2)
1. 1 exponentiation in $\Gr_2$ (for RHS in pairing #3; $\approx$ 72 $\mu$s)
1. 1 group operation in $\Gr_2$ (for RHS in pairing #3)
1. 1 size-2 multiexp in $\Gr_1$ (for LHS in pairing #4; $\ll$ 144 $\mu$s)
1. a size-4 multipairing ($\approx$ 1 ms)

{: .note}
Some approximate run-times when implementing on [BLS12-381 via blstrs on an Apple M1 Pro](/pairings#bls12-381-performance).

### Prover time

You compute $q(X)$ in 6 FFTs (same algorithm as [computing the quotient polynomial in Groth16](/groth16#computing-hx)). 
You implicitly compute $r(X)$ by shifting over the coefficients of $c(X) - c(0)$.
You commit to $q$ via a size-$n$ multiexp. <!-- a(X) b(X) has degree (n-1)+(n-1) + 1 = 2n-1. Dividing it by X^n - 1 yields a degree n-1 q(X) --> 
You commit to $r$ via a size-$(n-1)$ multiexp.

## Why the degree checks?

Here's an attack example showcasing why we need to degree-bound $r(X)$ by checking $\deg{r} < n -1$ (not on $q(X)$, AFAICT).

Given a proof $Q(X)$ and $R(X)$ for a sum $S$ such that Eq. \ref{eq:univariate-sumcheck} holds, a malicious prover could forge a proof $Q'(X), R'(X)$ for a different sum $S'$ by setting:
\begin{align}
S' &= S + t n\\\\\
q' &= q + t\\\\\
r' &= r - tX^{n-1}
\end{align}

Specifically, the univariate sumcheck from Eq. \ref{eq:univariate-sumcheck} would still hold for $q'$ and $r'$ and the incorrect sum $S'\ne S$:
\begin{align}
 a(X)b(X) &= q'(X)(X^n-1) + r'(X)X + n^{-1} (S + tn)\Leftrightarrow\\\\\
 a(X)b(X) &= (q(X)+t)(X^n-1) + (r(X)-tX^{n-1})\cdot X + n^{-1}(S+tn)\Leftrightarrow\\\\\
 a(X)b(X) &= \left(q(X)(X^n-1) + r(X)X + n^{-1} S\right) +
             \left(t(X^n-1) - tX^{n-1}\cdot X + n^{-1}(tn)\right)\Leftrightarrow\\\\\
 0 &= t(X^n-1) - tX^{n-1}\cdot X + n^{-1}(tn)\Leftrightarrow\\\\\
 0 &= tX^n - t - tX^n + t\Leftrightarrow\\\\\
 0 &= 0
\end{align}

## References

For cited works, see below 👇👇

{% include refs.md %}
