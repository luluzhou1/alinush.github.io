---
tags:
title: The sumcheck protocol
#date: 2020-11-05 20:45:59
published: false
permalink: sumcheck
#sidebar:
#    nav: cryptomat
#article_header:
#  type: cover
#  image:
#    src: /pictures/.jpg
---

{: .info}
**tl;dr:** The sumcheck protocol is a surprisingly-powerful technique for (zero-knowledge) argument systems.
In this short blog post, I will try to summarize it for my own benefit and, hopefully, yours too.

<!--more-->

<!-- Here you can define LaTeX macros -->
<div style="display: none;">$
\def\b{\boldsymbol{b}}
\def\bin{\{0,1\}}
\def\binMu{\{0,1\}^\mu}
$</div> <!-- $ -->

{% include mle.md %}

## Preliminaries

 - $\F$ is a prime-order finite field
 - $f(X_1,X_2,\ldots,X_\mu)$ denotes a $\mu$-variate polynomial with coefficients in $\F$.
 - $\deg_j(f)$ is the highest degree of $f$ in the variable $X_j$
 - $f$ is said to be **multilinear** when $\deg_j(f) = 1$ for all $j\in[\mu]$
 - a **multilinear extensions (MLE)** of a vector $\vec{v} = [v_0,\ldots,v_{2^\mu -1}]$ is a multilinear polynomial $f$ such that $f(i_1,i_1,\dots,i_\mu) = v_i$ where $i= \sum_{j=1}^{\mu} i_j \cdot 2^{j-1}$
    + this is the multivariate counterpart of [univariate polynomials interpolated from a vector](/2022/07/28/lagrange-interpolation.html)
 - we often work with the **boolean hypercube** $\binMu$
    + a fancy name for: _"all the bit-strings of size $\mu$"_
 - we denote vectors by bolded variables: e.g., $\x \bydef [x_1, x_2, \ldots, x_n]$
 - $\b$ is often used to denote a bit vector of size $\mu$ 

## What is the sumcheck protocol?

The sumcheck protocol allows a **prover** to convince a **verifier** that:

\begin{align}
\label{rel:sumcheck}
H &= \sum_{\b \in \binMu} f(b_1,b_2,\ldots,b_\mu)\\\\\
  &= \sum_{b_1 \in \bin} \sum_{b_2 \in \bin} \cdots \sum_{b_\mu \in \bin} f(b_1,b_2,\ldots,b_\mu)\\\\\
\end{align}

Both the prover and the verifier have $f$.

Note that we are summing all evaluations of $f$ over $\binMu$, which is often called the **boolean hypercube**.

The protocol requires the prover to compute $O(2^\mu)$ polynomial evaluations of $f$ (which is inherently necessary) but, **surprisingly**, only requires the verifier to compute **just one** polynomial evaluation of $f$.

What makes the sumcheck protocol so **amazing**:
 1. It saves a **lot** of work for the verifier, who would otherwise have to compute $O(2^\mu)$ evaluations of $f$ to verify $H$
 1. It has a small proof of size: $\sum_{j\in[\mu]} (\deg_j(f) + 1)$ elements in $\F$ 
    + e.g., when $f$ is multilinear, the proof size is $2\mu$!
    - e.g., when $f$ has max degree $d$ in _any_ variable, the proof size is $\sum_{j\in[mu]} (d+1) = (d+1)\mu$ elements in $\F$

In most settings (e.g., succinct, possibly zero-knowledge, arguments), the verifier will not have $f$ but an **oracle** to $f$ (e.g., a polynomial commitment of $f$).
We will touch upon this at times.

## Key idea behind sumcheck

The sumcheck protocol is a recursive protocol.

The **key idea** is: reduce a sumcheck of size $\mu$ to a sumcheck of size $\mu-1$ by replacing the current variable $X_1$ with a random value $r_1\in \F$ from the verifier.

We do this until we "run out" of variables and the verifier is simply left with the task of evaluating $f(r_1, r_2,\ldots,r_\mu)$.

Here's how it begins:

 - The prover computes the univariate polynomial $g_1(X) = \sum_{b_2 \in \bin} \cdots \sum_{b_\mu \in \bin} f(X, b_2,\ldots,b_\mu)$.
    + Note the exclusion of $\sum_{b_1\in\bin}$
 - The prover sends $g_1(X)$ to the verifier
 - The verifier checks that:
   + $g_1(X)$ is of degree $\deg_j(f)$
   + The sum $H = g_1(0) + g_1(1)$, as it should be (by definition of $H$ and $g_1$).


## The sumcheck protocol (the how)



## Properties of the sumcheck protocol

 - the sumcheck protocol works over any set $S^\mu$, not just $\binMu$
 - the soundness error is $\le \frac{\mu d}{\vert \F \vert}$, where $d = \max_j (\deg_j(f))$
    + for elliptic curve fields, $\vert \F \vert \approx 2^{256}$, so this error is negligible
 - the prover's overhead is only a constant factor higher than what is required to compute the sum $H$ itself
    + **TODO:** clarify how much higher
 - the verifier's messages are completely independent of the polynomial $f$
 - the verifier is only parameterized by (1) the number of variables $\mu$ and (2) the max degrees of each variable $\deg_j(f),\forall j\in[\mu]$,
    + because it needs to check the degrees of the univariate polynomials $g_j$ sent by the prover
 - the verifier only needs to compute one random evaluation $f(r_1, r_2, \ldots, r_\mu)$
    + alternatively, the verifier can simply verify this evaluation from an oracle, perhaps implement via polynomial commitment scheme (PCS)
 - the prover can be optimized when $f$ is a multilinear extension (MLE) or a product of MLEs

## Acknowledgements

Most of this write-up is a re-transcription of Justin Thaler's notes[^Thal20], as an excercise in making sure I understand things well enough.

## PWS

The sumcheck interactive proof (IP) relation $\mathcal{R}\_\mathsf{sum}^\mathsf{IP}$ (note that there is no secret witness):

\begin{align}
%\label{rel:sumcheck}
\mathcal{R}\_\mathsf{sum}^\mathsf{IP}(f, H; \cdot) = 1 \Leftrightarrow H = \sum_{b_1 \in \bin} \sum_{b_2 \in \bin} \cdots \sum_{b_\mu \in \bin} f(b_1,b_2,\ldots,b_\mu)
\end{align}

---

 + i.e., define the univariate polynomial $\hat{f}_j = f(0, 0, \ldots, X_j, \ldots, 0)$; then, $\deg_j(f) = \deg(\hat{f}_j)$

---

{% include refs.md %}
