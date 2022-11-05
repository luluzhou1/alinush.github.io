---
tags:
title: Pairings or bilinear maps
#date: 2020-11-05 20:45:59
published: false
sidebar:
    nav: cryptomat
---

A _pairing_, also known as a _bilinear map_, is a function $e : \Gr_1 \times \Gr_2 \rightarrow \Gr_T$ between three groups $\Gr_1, \Gr_2$ and $\Gr_T$ of prime order $p$ which has a couple of useful properties for cryptography:
<!--more-->

1. **Bilinear:** for all $u\in\Gr_1$, $v\in\Gr_2$, and $a,b\in\Zp$:

$$e(u^a, v^b) = e(u, v)^{ab}$$

2. **Non-degenerate:**

<p hidden>$$
\def\Adv{\mathcal{A}}
\def\Badv{\mathcal{B}}
\def\vect#1{\mathbf{#1}}
$$</p>

---

{% include refs.md %}
