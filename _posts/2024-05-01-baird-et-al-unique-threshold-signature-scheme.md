---
tags:
 - digital signatures
 - dkg
 - distributed key generation
 - aggregation
 - bilinear maps (pairings)
title: Baird et al.'s unique threshold signature scheme
#date: 2020-11-05 20:45:59
published: true 
sidebar:
    nav: cryptomat
---

{: .info}
In this post, we describe a [strawman threshold signature construction](/pictures/2024-05-08-mts.png) by Baird et al.[^BGJplus23] which produces _unique signatures_.
In their paper, Baird et al. modify this construction into a (non-unique) **multiverse** threshold signature scheme.

<!--more-->

## Preliminaries

We assume familiarity with:
 - [Bilinear maps](/2022/12/31/pairings-or-bilinear-maps.html)
 - [Lagrange polynomials](/2022/07/28/lagrange-interpolation.html)

## The idea

The Baird et al. strawman[^BGJplus23] follows a very **simple idea**.

Each player $i\in[n]$ locally picks their secret key $\sk_i$ and computes their public key as $\pk_i = g^{\sk_i}$.
Then, the SKs of a set of $n$ players can be used to define a degree-$(n-1)$ polynomial $f(X)$ as follows:
\begin{align}
f(i) &= \sk_i,\forall i \in[n]
\end{align}
To create a $t$-out-of-$n$ threshold signature scheme, the players can **collaborate** (in an MPC/DKG-like fashion), to publicly-reveal $n-t$ evaluations of this polynomials.
This effectively reduces the degree of the polynomial to be $t-1$.

{: .warning}
**Open question:** Can this protocol for publicly-revealing the $n-t$ evaluations can be instantiated any more efficiently than a DKG?

Specifically, the players use (some) DKG-like protocol to reveal:
\begin{align}
\mathsf{evals} = \left(f(-1), f(-2),\ldots,f(-(n-t))\right)
\end{align}
The secret key of the resulting $t$-out-of-$n$ threshold signature scheme is defined as:
\begin{align}
\sk = f(0)
\end{align}
The associated PK consists of the publicly-revealed evaluations and, of course, $g^{f(0)}$:
\begin{align}
\pk = (\mathsf{evals}, g^\sk) = \left(\mathsf{evals}, g^{f(0)}\right) = \left(\mathsf{evals}, \prod_{i\in[n]} \pk_i\right)
\end{align}
To assemble a threshold signature on a message $m$, each player $i$ reveals their **signature share** $H(m)^{\sk_i}$.
Then, any aggregator who has $\pk$ and $t$ signature shares, can interpolate the **unique** threshold signature $H(m)^{f(0)}$ from (1) the signature shares and (2) the publicly-reveled evaluations in $\pk$.

We give more details below.

## The construction

Below, we formally give the Baird et al. strawman[^BGJplus23].

$\mathsf{Sig}$.$\mathsf{KeyGen}(1^\lambda) \rightarrow (\sk, \pk)$:
 - $\sk\randget\Zp$  
 - $\pk \gets g^\sk$

$\mathsf{Sig}$.$\mathsf{DistKeyGen}(t, (\sk_i, \pk_i)_{i\in[n]}) \rightarrow (\sk, \pk)$:
 - Let $\ell_i = \prod_{j\in [n], j\ne i} \frac{0 - j}{i - j}$ be the Lagrange coefficients w.r.t. to $[n]$ 
 - Let $f(X) = \sum_{i\in[n]} \ell_i \sk_i$ be a polynomial such that $f(i) = \sk_i$
 - Let $\sk \gets f(0)$
 - Let $\pk \gets (g^\sk, f(-1), f(-2), \ldots, f(-(n-t))$

{: .info}
The $\mathsf{Sig.DistKeyGen}$ algorithm is run by the players in an MPC fashion such that it outputs the $\pk$ of the threshold signature scheme yet no one learns the $\sk$.

$\mathsf{Sig}$.$\mathsf{ShareSign}(\sk_i, m) \rightarrow \sigma_i$:
 - $\sigma_i \gets H(m)^{\sk_i}$

$\mathsf{Sig}$.$\mathsf{ShareVer}(\pk_i, m, \sigma_i) \rightarrow \\{0,1\\}$:
 - Return $e(\sigma_i, g) \equals e(H(m), \pk_i)$

$\mathsf{Sig}$.$\mathsf{Aggregate}(\pk, m, (\sigma\_i)\_{i\in T}) \rightarrow \sigma$:
 - Assert $\|T\| \ge t$ and $T \subseteq [n]$.
 - Let $P = \\{-1, -2,\ldots, -(n-t)\\}$ denote the publicly-revealed evaluation points in $\pk$
 - Let $\ell_i = \prod_{j\in P\cup T, j\ne i} \frac{0 - j}{i - j}$ be the Lagrange coefficients w.r.t. to $P\cup T$ 
 - Let $(\cdot, f(-1), f(-2), \ldots, f(-(n-t)) \gets \pk$
 - $\sigma \gets \prod_{i\in T} \sigma_i^{\ell_i} \prod_{i\in P} H(m)^{\ell_i f(i)}$

$\mathsf{Sig}$.$\mathsf{Verify}(\pk, m, \sigma) \rightarrow \\{0,1\\}$:
 - Return $e(\sigma, g) \equals e(H(m), \pk)$

## Conclusion

This is a very nice scheme, but it has a few problems:

 1. It is unclear how to _efficiently_ reveal the evaluations in $\mathsf{evals}$
 2. It is not secure in the multiverse setting (see how [BGJ+23][^BGJplus23] fixes it)

<!--
## Attempt to fix strawman from \[BGJ+23e\][^BGJplus23]

{: .warning}
**Oh... problem:** $g^{f(0)}$ can be predicted ahead of time $\Rightarrow$ if VUF is $e(g^{f(0)}, H(m)) = e(\sigma^\mathsf{pub}, H(m)) \cdot e(g, \sigma^\mathsf{priv})$, as per [BGJ+23e], then it's predictable.
[BGJ+23e] gives a ZKPoK of $\sigma^\mathsf{pub}$ w.r.t the PKs, but this doesn't make the pairing above any less predictable. 
That's why they rely on the unpredictable, **non-unique** $\sigma^\mathsf{priv}$ as part of their signature.

$\mathsf{Sig}$.$\mathsf{KeyGen}(1^\lambda) \rightarrow (\sk, \pk)$:
 - $\sk\randget\Zp$  
 - $\pk \gets g^\sk$

$\mathsf{Sig}$.$\mathsf{ShareSign}\_\sk(m) \rightarrow \sigma$:
 - $\sigma \gets H(m)^\sk$

$\mathsf{Sig}$.$\mathsf{ShareVer}\_\pk(m, \sigma) \rightarrow \\{0,1\\}$:
 - Return $e(\sigma, g) \equals e(H(m), \pk)$

$\mathsf{Sig}$.$\mathsf{Aggregate}(m, (\sigma\_i)\_{i\in T}, (\pk_j)_{j\in [n]}) \rightarrow \\{\sigma, \pi\\}$:
 - Assert $\|T\| \ge t$ and $T \subseteq [n]$.
 - Let $D = \\{-1, -2,\ldots, -(n-t)\\} \cup T$ denote the evaluation domain
 - Let $\ell_i = \prod_{j\in D, j\ne i} \frac{0 - j}{i - j}$ be the Lagrange coefficients w.r.t. to $D$ 
 - $\sigma^{\mathsf{priv}} \gets \prod_{i\in T} \sigma_i^{\ell_i}$
 - $\sigma^{\mathsf{pub}} \gets  \prod_{j\in D\setminus T} \pk_j^{\ell_j}$
 - $\pi = $ ?? 
 - (**Note:** $\sigma^\mathsf{pub}\cdot \sigma^\mathsf{priv} = H(m)^{f(0)}$, where $f(X)$ is the polynomial such that $f(i) = \sk_i$ for each player $i \in [n]$)

$\mathsf{Sig}$.$\mathsf{Verify}(m, \sigma, \pi, (\pk\_i)\_{i\in [n]}) \rightarrow \\{0,1\\}$:
 - ??
-->

---

{% include refs.md %}
