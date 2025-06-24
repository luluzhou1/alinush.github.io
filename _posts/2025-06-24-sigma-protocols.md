---
tags:
 - zero-knowledge proofs (ZKPs)
 - sigma protocols
title: $\Sigma$-protocols
#date: 2020-11-05 20:45:59
#published: false
permalink: sigma
sidebar:
    nav: cryptomat
#article_header:
#  type: cover
#  image:
#    src: /pictures/.jpg
---

{: .info}
**tl;dr:** A quick note on the most commonly-occuring variant of $\Sigma$-protocols.

<!--more-->

<!-- Here you can define LaTew macros -->
<div style="display: none;">$
\def\P{\mathcal{P}}
\def\V{\mathcal{V}}
\def\str{\mathsf{str}}
\def\binL{\{0,1\}^{2\lambda}}
$</div> <!-- $ -->

## Introduction

Skipping over 30+ years of $\Sigma$-protocol design and jmping right into it.

## Preliminaries

 - $[m]\bydef\\{1,\ldots,m\\}$
 - $\bigwedge_{i \in [m]} C_i \bydef C_1 \wedge C_2\wedge\ldots C_m$ denotes the logical "and" of multiple statements $C_i$
 - $\lambda$ denotes a security parameter; typically $\lambda = 128$ bits of security
 - $\F$ is a finite field of prime order $p \approx 2^{2\lambda}$
 - $\Gr$ is a group where computing discrete logs is hard, also of prime order $p$
 - We are using additive group notation for $\Gr$ (e.g., $P_1 + P_2\in\Gr$ and $a\cdot P\bydef \underbrace{P+P+\ldots+P}_{a\ \text{times}}\in \Gr$). 
 - $\N$ denotes all the natural numbers

## $\Sigma$-protocols for linear relations

Consider a **linear check** of the form on group elements $G_j\in\Gr$:
\begin{align}
U \equals
\sum_{j\in [n]} w_j \cdot G_j 
\end{align}

Denote the "logical and" of a bunch of such checks on the same inputs $w_1, \ldots, w_n\in\F$ by:
\begin{align}
\term{\phi(w_1,\ldots,w_n)} \bydef \left\\{
\bigwedge_{i\in[m]}\left( \term{U_i} \equals \sum_{j\in[n]} \term{w_j}\cdot \term{G_{i,j}}\right)
\right\\}
\end{align}

Boneh and Shoup[^BS23] show that it is very easy to build $\Sigma$-protocols for this general class of **arbitrary linear relations**; i.e., for:
\begin{align}
\term{\mathcal{R}_\mathsf{lin}}\begin{pmatrix}
    (G\_{i,j})\_{i\in[m],j\in[n]}, (U\_i)\_{i\in[m]}
    \textbf{;}\\\\\
    w_1,\ldots,w_n\end{pmatrix} = 1
    \Leftrightarrow
    \phi(w_1,\ldots,w_1) \equals 1
\end{align}

A $\Sigma$-protocol for $\mathcal{R}_\mathsf{lin}$, where a **prover** $\P$ convinces the **verifier** $\V$, in zero-knowledge, that it knows secret $w_i$'s such that $\phi(w_1,\ldots,w_n)=1$ follows below:

<table style="border-collapse: collapse; border: 1px solid grey; table-layout: fixed; width: 575px;">
<tr><td style="border: none;">
  $\underline{\P\begin{pmatrix}(G_{i,j})_{i\in[m],j\in[n]}, (U_i)_{i\in[m]}\textbf{;}\\\, (w_i)_{i\in[n]}\end{pmatrix}}$
</td><td style="border: none; text-align: right;">
  $\underline{\V\left((G_{i,j})_{i\in[m],j\in[n]}, (U_i)_{i\in[m]}\right)\rightarrow \{0,1\}}$
</td></tr>

<tr><td style="border: none; text-align: left;" colspan="2">
  $\term{\alpha_j} \randget\F, \forall j\in[n]$<br />
  $\term{A_i}\gets  \sum_{j\in[n]} \alpha_j\cdot G_{i,j},\forall i\in[m]$<br />
</td></tr>

<tr><td style="border: none; text-align: center;" colspan="2">
  $\xrightarrow{\hspace{1.5em}\mbox{$A_1,\ldots, A_m$}\hspace{1.5em}}$
</td></tr>

<tr><td style="border: none; text-align: right;" colspan="2">
  $\term{e} \randget \F$<br/>
</td></tr>

<tr><td style="border: none; text-align: center;" colspan="2">
  $\xleftarrow{\hspace{1.5em}\mbox{$e$}\hspace{1.5em}}$
</td></tr>

<tr><td style="border: none; text-align: left;" colspan="2">
  $\term{\sigma_j} \gets \alpha_j + e\cdot w_j,\forall j\in[n]$<br />
</td></tr>

<tr><td style="border: none; text-align: right;" colspan="2">
  $A_i + e \cdot U_i \equals \sum_{j\in[n]}\sigma_j\cdot G_{i,j},\forall i\in[m]$<br/>
</td></tr>
</table>

{: .note}
This protocols works across _different groups_: i.e., when $U_i, G_{i,j}\in \Gr_i$ and the $\Gr_i$'s are different but of the same prime order $p$!
(However, the faster verification optimization [described below](#performance) will be affected.)

## Implementation pitfalls

### Performance

The description above does not account for an important optimization used in practice to make the verifier faster: using multi-scalar multiplication (MSM) in the last step, when the verifier checks $A_i + e\cdot U_i \equals \sum_{j\in[n]} \sigma_j \cdot G_{i,j}$.

How?

The verifier picks **random**, $\lambda$-bit wide $\beta_i$'s.
Note that, for the $i$th equation, the verifier could, in principle, equivalently check:
\begin{align}
\beta_i \cdot \left(A_i + e \cdot U_i\right) &\equals \beta_i \left(\sum_{j\in[n]}\sigma_j\cdot G_{i,j}\right)\Leftrightarrow\\\\\
\beta_i \cdot \left(A_i + e \cdot U_i + \sum_{j\in[n]}\sigma_j\cdot G_{i,j}\right) &\\equals 0\\\\\
\beta_i \cdot A_i + (\beta_i \cdot e) \cdot U_i + \sum_{j\in[n]}(\beta_i \cdot \sigma_j)\cdot G_{i,j} &\\equals 0
\end{align}
Then, the verifier simply adds all these checks together, resulting in a single check:
\begin{align}
\sum_{i\in [m]}\left( \beta_i\cdot A_i + (\beta_i \cdot e) \cdot U_i\right) + \sum_{i\in[m],j\in[n]}\left( (\beta_i \cdot \sigma_j) \cdot G_{i,j}\right) &\\equals 0
\end{align}
One can show that, except with negligible probability, this batched check is as $\approx$ as sound as the original check:

{: .note}
The check above is now a single size-$(nm + m)$ MSM!

### Secure deserialization

$\Sigma$-protocol proofs are usually sent over the network to the verifier $\V$.

Therefore, a crucial security-sensitive operation is never captured in academic descriptions like the one above:
**the verifier must correctly-deserialize the received proof into group and field elements**!

Always make sure your group element deserialization routine in the elliptic curve library you are using checks two things:
1. The deserialized point satisfies the elliptic curve equation
2. The deserialized point lies in the subgroup of prime order $p = \|\F\| = \|\Gr\|$
    + Most deployed cryptography only works over prime order subgroups and big security issues can arise otherwise (see [here](/schnorr#fn:devalence))

Be careful how you handle deserialization of field elements too:
1. A conservative approach is to always reject bytes that encode a number $\ge p$, since field elements are in $[0, p)$.

### Fiat-Shamir transform

Hash everything: a description of $\Gr$ (e.g., _"Edwards 25519"_), the prime order $p$, the sizes $n,m$, all the $G_{i,j}$'s, all the $U_i$'s, all the messages so far (i.e., the $A_i$'s), and any application-specific context $\mathsf{ctx}$.

Specifically:
\begin{align}
\mathsf{ctx} &\gets \text{"withdrawal protocol / Aptos confidential assets"}\\\\\
e &\gets H\_\mathsf{FS}(\mathsf{desc}(\Gr), p, n, m, (G\_{i,j})\_{i\in[m],j\in[n]}, (U\_i, A\_i)\_{i\in[m]}, \mathsf{ctx})
\end{align}
where $H_\mathsf{FS}$ is a cryptographic hash function:
\begin{align}
H\_\mathsf{FS} : \str \times \N^3 \times \Gr^{mn} \times \Gr^{2m}\times \str\rightarrow \binL
\end{align}

However, even this description can be **dangerously misleading** as it assumes people know how to instantiate collision-resistant $H\_\mathsf{FS}$ given a more general collision-resistant hash function $H : \\{0,1\\}^\*\rightarrow \binL$ that just hashes bit streams.

Yet, in practice, people implement this wrong.

For example, imagine a hash function $H_2 : \str \times \str \rightarrow \binL$ for hashing two strings $s_1,s_2 \in \str$, but **mis**implemented to hash them by concatenating them as $H(s_1 \concat s_2)$ using the general hash function $H$ from above.
If so, then the hash of $s_1 = \text{"a"}$ and $s_2 = \text{"bc"}$ will collide with that of $s_1' = \text{"ab"}$ and $s_2' = \text{"c"}$ will collide, since they are both $H_2(\text{"a"},\text{"bc"})=H_2(\text{"ab"},\text{"c"})=H(\text{"abc"})$.

{: .warning}
$\Rightarrow$ Just use the [spongefish library](https://github.com/arkworks-rs/spongefish), really[^CO25e].

{: .warning}
Be sure to not hash unecessary stuff.
e.g., don't hash arbitrary stuff "just for safety", since this may open up grinding attack vectors.

{: .warning}
You'd find out the hard way, but don't hash the secret witness (e.g., the $w_i$'s), because both the prover **and** the verifier need to be able to compute the hash, and the verifier doesn't have the witness, since $\Sigma$-protocols are ZK!

## Extra resources

 - Composing $\Sigma$-protocols can also be tricky. Hope to add notes here later.
 - ZKProof workshop $\Sigma$-protocols proposal[^KO21] with [slides here](https://docs.zkproof.org/pages/standards/slides-w4/sigma.pdf)
 - Ivan Damgaard's write-up[^Dam10]

## References

For cited works, see below 👇👇

{% include refs.md %}
