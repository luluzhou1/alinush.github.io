---
tags:
title: BBS+ signatures
#date: 2020-11-05 20:45:59
#published: false
sidebar:
    nav: cryptomat
#article_header:
#  type: cover
#  image:
#    src: /pictures/.jpg
---

{: .info}
**tl;dr:** BBS+ is a transformation[^ASM08e] of the the _Boneh-Boyen-Shacham (BBS)_ **group** signature scheme[^BBS04] into a **standalone** signature scheme.
This blog post describes BBS+ as well as a recent improvement over it dubbed **standalone BBS**[^TZ23e].

## Why BBS+?

The [BBS+](#the-bbs-signature-scheme) and [standalone BBS](#the-standalone-bbs-signature-scheme) schemes have some really **nice properties**:

 - Can sign a vector of field elements $(m_1,m_2,\ldots,m_\ell)\in \Zp$
   + The signing can be done blindly over a Pedersen vector commitment $C = h_0^r \prod_{i\in[\ell]} h_i^{m_i}$, where $r \randget \Zp$ is a uniformly-picked blinding factor.
   + This way, the signer gets the commitment $C$ to sign and never sees the messages $m_i$ themselves
      + **TODO:** show in a separate section
 - Does not rely on random oracles
 - It is as efficient to verify as BLS[^BLS01] signatures: a size-2 multipairing

These properties makes BBS+ (and standalone BBS) very useful for building **anonymous credential (AC)** schemes.
(In a future post, I hope to constrast BBS+ with other schmes like CL or [Pointcheval-Sanders (PS)](/2023/01/08/Pairing-based-anonymous-credentials-and-the-power-of-re-randomization.html).)

## Preliminaries
 
 - There is a [bilinear map](/2022/12/31/pairings-or-bilinear-maps.html) $e : \Gr_1 \times \Gr_2 \rightarrow \Gr_T$, where $\Gr_1 = \langle g_1 \rangle, \Gr_2 = \langle g_2 \rangle$ and $\Gr_T$ are of prime order $p$
 - Let $\Zp = \\{0,1,2,\ldots,p-1\\}$ denote the finite field of order $p$. 
 - A Pedersen commitment to a vector $(m_1,\ldots,m_\ell) \in \Zp^\ell$ is $C = h_0^r \prod_{i\in[\ell]} h_i^{m_i}$, where $r \randget \Zp$ is a uniformly-picked blinding factor and $(h_0,\ldots,h_\ell)$ are fixed generators in a group $\Gr$ of order $p$ whose pairwise discrete logs are unknown.

## The BBS+ signature scheme

{: .info}
BBS+ is slightly less efficient than [standalone BBS](#the-standalone-bbs-signature-scheme), so it should probably be dropped in favor of the latter.

$\mathsf{BBS+}$.$\mathsf{KeyGen}(1^\lambda, \ell) \rightarrow (\sk, \pk)$:
 - $\mathbf{h} \stackrel{\mathsf{def}}{=} (h_0, h_1 \ldots, h_{\ell}) \gets \Gr_1^{\ell+1}$
 - $x \randget \Zp$
 - $y \gets g_2^x$
 - $\sk \gets (x, \mathbf{h})$
 - $\pk \gets (y, \mathbf{h})$

$\mathsf{BBS+}$.$\mathsf{Sign}((m_1,\ldots,m_\ell), \sk) \rightarrow \sigma$:
 - $(x, \mathbf{h}) \gets \sk$
 - $(e, s)\randget \Zp^2$
 - $C \gets g_1 h_0^s \prod_{i\in[\ell]} h_i^{m_i}$
    + **Note:** This is a Pedersen-like commitment to the $m_i$'s. (Except it is not blinded, since the randomness $s$ is publicly-exposed as part of the signature.) 
 - $\sigma \stackrel{\mathsf{def}}{=} (A, e, s) \gets (C^\frac{1}{x + e}, e, s)$

{: .info}
**TODO:** Does reusing randomness break anything?

$\mathsf{BBS+}$.$\mathsf{Verify}((m_1,\ldots,m_\ell), \pk, \sigma) \rightarrow \\{0,1\\}$:
 - $(y,\mathbf{h})\gets \pk$ 
 - $(A, e, s)\gets \sigma$
 - $C \gets g_1 h_0^s \prod_{i\in[\ell]} h_i^{m_i}$
 - **assert** $e(A, y \cdot g_2^e) \stackrel{?}{=} e(C, g_2)$


**Correctness:**
It is easy to see why correctness holds (i.e., signatures produced by $\mathsf{BBS+}.\mathsf{Sign}$ pass verification in $\mathsf{BBS+}.\mathsf{Verify}$):
\begin{align}
e(A, y \cdot g_2^e) &\stackrel{?}{=} e(C, g_2)\\\\\
e(C^\frac{1}{x + e}, g_2^x \cdot g_2^e) &\stackrel{?}{=} e(C, g_2)\\\\\
e(C^\frac{1}{x + e}, g_2^{x + e}) &\stackrel{?}{=} e(C, g_2)\\\\\
e(C, g_2) &\stackrel{?}{=} e(C, g_2)
\end{align}

## The standalone BBS signature scheme

BBS+ was a transformation of the BBS group signature scheme[^BBS04] into a standalone signature scheme by Au et al.[^ASM08e].
Unfortunately, this transformation increased the size of the signature from $(A, e)\in\Gr\times\Zp$ to $(A, e, s)\in\Gr\times\Zp^2$.
The $s$ component had to be included only so that the security proof could pass.
Recently, however, Tessaro and Zhu[^TZ23e] gave a security proof for BBS+ without an $s$-component, which they dubbed **standalone BBS signatures**.

{: .info}
I guess the alternative BBS++ name would have been worse?
On the other hand "[standalone] BBS"[^TZ23e] stands to be confused with the BBS [group] signature scheme[^BBS04].

Naming issues aside, Tessaro and Zhu's **standalone BBS (sBBS)** scheme's decription follows below.
(It is denoted as $\mathsf{sBBS}$ to avoid confusing it with the $\mathsf{BBS}$ group signature scheme.)

$\mathsf{sBBS}$.$\mathsf{KeyGen}(1^\lambda, \ell) \rightarrow (\sk, \pk)$:
 - (This is almost the same as in BBS+, except only $\ell$ $h_i$'s are needed.)
 - $\mathbf{h} \stackrel{\mathsf{def}}{=} (h_1, \ldots, h_\ell) \gets \Gr_1^{\ell}$
 - $x \randget \Zp$
 - $y \gets g_2^x$
 - $\sk \gets (x, \mathbf{h})$
 - $\pk \gets (y, \mathbf{h})$

$\mathsf{sBBS}$.$\mathsf{Sign}((m_1,\ldots,m_\ell), \sk) \rightarrow \sigma$:
 - $(x, \mathbf{h}) \gets \sk$
 - $e\randget \Zp$
 - $C \gets g_1 \prod_{i\in[\ell]} h_i^{m_i}$
    + **Note:** This is a Pedersen-like commitment to the $m_i$'s. (Except it is not blinded.)
 - $\sigma \stackrel{\mathsf{def}}{=} (A, e) \gets (C^\frac{1}{x + e}, e)$

{: .info}
Signing is slightly faster than in BBS+ because there is no $h_0^s$

$\mathsf{sBBS}$.$\mathsf{Verify}((m_1,\ldots,m_\ell), \pk, \sigma) \rightarrow \\{0,1\\}$:
 - $(y,\mathbf{h})\gets \pk$ 
 - $(A, e)\gets \sigma$
 - $C \gets g_1 \prod_{i\in[\ell]} h_i^{m_i}$
 - **assert** $e(A, y \cdot g_2^e) \stackrel{?}{=} e(C, g_2)$

{: .info}
Unlike in BBS+, the requirement on picking $e$ is simpler: $e$ does not have to be picked uniformly at random. Instead, we only need to make sure $e$'s don't collide. A simple way can be to simply treat $e$ as an always-increasing counter. Or, to derive it pseudo-randomly from the message (via hashing).

## Conclusion

BBS+ (and/or standalone BBS) are versatile signature schemes (e.g., can sign [commitments to] field element(s) without random oracles, can verify as fast as BLS[^BLS01], etc.).

However, like any signature scheme, they have their **disadvantages**:
 - **Larger signatures** for BBS+: 1 group element and 2 field elements.
    + Standalone BBS has _smaller_ signatures: 1 group element and 1 field element.
 - They **do not "thresholdize" very well**: $t$-out-of-$n$ threshold protocols for BBS+ (and standalone BBS) either require offline preprocessing or multiple rounds of interaction between signers.
 - Signing **requires randomness**.
 - Signatures are **not re-randomizable**[^PS16]. (It may be sufficient to expose $h_0^\frac{1}{x+e}$ next to each signature $(A,e)$ to allow for re-randomizability?)
<!--more-->

<!-- Here you can define LaTeX macros -->
<div style="display: none;">$
$</div>

---

{% include refs.md %}
