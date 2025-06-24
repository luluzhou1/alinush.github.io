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
\def\prover{\mathcal{P}}
\def\verifier{\mathcal{V}}
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

A $\Sigma$-protocol for $\mathcal{R}_\mathsf{lin}$, where a **prover** $\prover$ convinces the **verifier** $\verifier$, in zero-knowledge, that it knows secret $w_i$'s such that $\phi(w_1,\ldots,w_n)=1$ follows below:

<table style="border-collapse: collapse; border: 1px solid grey; table-layout: fixed; width: 575px;">
<tr><td style="border: none;">
  $\underline{\prover\begin{pmatrix}(G_{i,j})_{i\in[m],j\in[n]}, (U_i)_{i\in[m]}\textbf{;}\\\, (w_i)_{i\in[n]}\end{pmatrix}}$
</td><td style="border: none; text-align: right;">
  $\underline{\verifier\left((G_{i,j})_{i\in[m],j\in[n]}, (U_i)_{i\in[m]}\right)\rightarrow \{0,1\}}$
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

### Secure deserialization via subgroup checks 

Always make sure your deserialization routine in the library you are using checks two things:
1. The deserialized point satisfies the elliptic curve equation
2. The deserialized point lies in the subgroup of prime order $p = \|\F\| = \|\Gr\|$
    + Most deployed cryptography only works over prime order subgroups and big security issues can arise otherwise (see [here](/schnorr#fn:devalence))

### Fiat-Shamir transform

Hash everything: a description $\Gr$, the prime order $p$, the sizes $n,m$, all the $G_{i,j}$'s, all the $U_i$'s, all the messages so far (i.e., the $A_i$'s), and any application-specific context $\mathsf{ctx}$.

Specifically:
\begin{align}
\mathsf{ctx} &\gets \text{"withdrawal protocol / Aptos confidential assets"}\\\\\
e &\gets H\_\mathsf{FS}(\Gr, p, n, m, (G\_{i,j})\_{i\in[m],j\in[n]}, (U\_i, A\_i)\_{i\in[m]}, \mathsf{ctx})
\end{align}

{: .warning}
But don't hash too much either!
e.g., don't hash arbitrary stuff "just for safety", since this opens up grinding attack vectors.

{: .warning}
You'd find out the hard way, but don't hash the secret witness (e.g., the $w_i$'s), because both the prover **and** the verifier need to be able to compute the hash, and the verifier doesn't have the witness (since $\Sigma$-protocols are ZK!)

{: .warning}
Just use the [spongefish library](https://github.com/arkworks-rs/spongefish), really[^CO25e].

## References

For cited works, see below 👇👇

{% include refs.md %}
