---
tags:
title: ECDSA signatures (and why you should avoid them)
#date: 2020-11-05 20:45:59
#published: false
sidebar:
    nav: cryptomat
---

{: .info}
**tl;dr:** ECDSA is one of the most widely-deployed signature schemes (for better or worse).
ECDSA is _efficient_, offers _versatility_ via its _pubkey recovery_ feature and is widely adopted due to Bitcoin's success.
Its history is fascinating, as is its security analysis.
Nonetheless: you should **stay away from it**, as I argue [here](#why-you-should-avoid-ecdsa).

<!--more-->

<p hidden>$$
\def\Adv{\mathcal{A}}
\def\Badv{\mathcal{B}}
\def\vect#1{\mathbf{#1}}
$$</p>

## Preliminaries

 - Let $\lambda$ denote a security parameter (typically, set to 128)
 - Let $\Gr$ denote a group of prime order $p$, where $p \approx 2^{2\lambda}$, such that the discrete logarithm assumption is hard in $\Gr$
    - For ECDSA, $\Gr$ is an elliptic curve group[^Cost12]
    - In this case, we let $\Fq$ denote the base field of the elliptic curve group $\Gr$
 - Let $g$ denote the generator of $\Gr$
 - Let $\Zp$ denote the finite field of order $p$ that arises "in the exponent" of $g$
 - Let $\Zps=\\{1,2,3,\ldots,p-1\\}$ denote the multiplicative group of integers mod $p$
 - We assume a collision-resistant hash function $H : \\{0,1\\}^\* \rightarrow \Zp$
    + As per Brown's formalization of _AbstractDSA_[^Brow02].

## History

In 1985, nine years after Diffie-Hellman[^DH76], Taher ElGamal introduced a digital signature scheme and postulated it to be secure under the hardness of discrete logarithms[^Elga85].
Referred to as **ElGamal signatures**, this scheme leveraged the multiplicative group $\Zps$, where $p$ is a prime and $g$ is a [generator](/2021/04/15/basic-number-theory.html#finding-primitive-roots-mod-p).
ElGamal's intuition was that a signature $(r,s)$ for a message $m$ should satisfy:
\begin{align}
\label{eq:elgamal-intuition}
g^m &= \pk^r r^s \bmod p,\ \text{where}\ 0 \le r, s < p-1
\end{align}
<!--And, specifically, that if $r\gets g^k$ for a random $k$, then:
\begin{align}
\end{align}-->
So, ElGamal proposes to sign by "solving"[^elgamal-signing] for $r$ and $s$ as follows:
\begin{align}
k &\randget [0,p-1],\ \text{s.t.}\ \gcd(k, p-1) = 1\\\\\
r &\gets g^k \bmod p\\\\\
\label{eq:elgamal-sig-s}
s &\gets k^{-1}(m - \sk\cdot r) \bmod (p-1)
\end{align}

In 1991, NIST proposed a slight alternation of ElGamal signatures called **DSA signatures** for standardization as part of the _Digital Signatures Standard (DSS)_[^dss].
Unlike ElGamal, DSA assumed a prime $p = hq+1$ where $q$ is a also prime and $h$ is some other number (sometimes called a co-factor).
The signature now became:
\begin{align}
k &\randget [1,q)\\\\\
r &\gets (g^k \bmod p) \bmod q\\\\\
s &\gets k^{-1}(m + \sk\cdot r) \bmod q
\end{align}
DSA was more efficient, since it worked (mostly) over smaller primes $q$, when $p$ was picked appropriately.
It also allowed the signature $(r,s)\in[1,q)$ to be much smaller.

{: .note}
Not sure what the rationale was for changing ElGamal's $k^{-1}(m\textcolor{green}{-}\sk\cdot r)$ into DSA's $k^{-1}(m\textcolor{red}{+}\sk\cdot r)$.

In 1992, Scott Vanstone[^vanstone] proposed **ECDSA** in response to NIST's request for comments on their DSS proposal[^JMV01].
ECDSA is an elliptic curve variant of the DSA scheme, which [this blog post focuses on](#the-ecdsa-signature-scheme).

In 1993, a FOIA request[^foia] revealed that the DSA algorithm was designed not by NIST but by the NSA.

{: .info}
**Some speculation:** Some folks find the NSA's involvement in the DSA standard (and elliptic curve standards) suspicious. 
Perhaps for good reason, given the 2013 EC_DRBG fiasco[^ec-drbg]. 
Others find it reaffirms the security of these schemes[^certicom-ecc].

In 1998 and subsequently, ANSI, IEEE and NIST all standardized ECDSA.

In 1995, David Nccache et al. propose a [batch verification](#batch-verification) algorithm for verifying multiple DSA signatures faster[^NMVR95].
In 2007, Cheon and Yi introduce a batch verification algorithm for ECDSA[^CY07].

In 2002, Daniel L. Brown introduces ECDSA's [pubkey recovery](#pubkey-recovery-algorithm) algorithm[^Brow02]$^,$[^fgrieu-pubkey-recovery].

On January 3, 2009, Satoshi Nakamoto makes Bitcoin available to the public.
Bitcoin uses ECDSA over secp256k1 curves as its scheme for signing transactions.
Some believe Satoshi chose ECDSA because [Schnorr signatures](/2024/05/31/Schnorr-signatures.html) were, at the time, still patented.

{: .info} 
**Some more speculation**: My two cents are that this choice cemented ECDSA's reign in the cryptocurrency space.
Ethereum soon followed in Bitcoin's footsteps.
And all other blockchains followed in Ethereum's.

## The ECDSA signature scheme

In this section, we explain how key generation, signing and signature verification work in ECDSA.
To help the reader understand how ECDSA works, we show why ECDSA is _correct_ (i.e., honestly-computed signature pass verification).
We do not show why ECDSA is _secure_, since the security proofs can be a bit nuanced.
Lastly, we detail ECDSA's _pubkey recovery_ feature, which is often used in cryptocurrencies like Bitcoin and Ethereum.

{: .info}
It is **important** to understand that ECDSA only works with **eliptic curve** groups $\Gr$[^Cost12].
Such curves are "built" over a **base field** $\Fq$ such that each group element, or **point**, $P\in\Gr$ is represented by its $x$ and $y$ coordinates: i.e., $P=(x,y)\in\Fq^2$.

### The ECDSA "conversion function"

Another important detail about ECDSA is that it assumes a **conversion function** $f : \Gr \rightarrow \Zp$ that maps a group element into a non-zero field element, which works as follows:

$f(R) \rightarrow r\in \Zp$:
 1. Let $(x,y)\in\Fq^2$ denote the elliptic curve coordinates of point $R \in \Gr$
 1. Let $\bar{x}$ denote the integer representation of $x$
 1. $r\gets \bar{x} \bmod p$

### Algorithms

ECDSA key generation, signing and signature verification work as follows:

$\mathsf{ECDSA}$.$\mathsf{KeyGen}(1^\lambda) \rightarrow (\sk, \pk)\in\Gr^2$:
 - $\sk \randget \Zp\setminus\\{0\\}\ \textcolor{grey}{\text{// 0 is excluded as a valid SK}}$
 - $\pk \gets g^\sk$

$\mathsf{ECDSA}$.$\mathsf{Sign}(m, \sk) \rightarrow \sigma\in\Zp^2$:
 1. $k \randget \Zp\setminus\\{0\\}\ \textcolor{grey}{\text{// 0 is excluded as a valid nonce}}$
 1. $R\gets g^k$ 
 1. $r\gets f(R)$ (see the [conversion function](#the-ecdsa-conversion-function) above)
     - **if** $r\equals 0$, go back to **step 1**
 1. $s \gets k^{-1}(H(m) + \sk\cdot r) \bmod p$ 
     - **if** $s\equals 0$, go back to **step 1**
 1. $\sigma\gets (r,s)$

{: .info}
**Security:** It is _crucial_ that there be absolutely no bias when picking $k$.
It must pe picked uniformly at random in $\Zp\setminus\\{0\\}$.
Otherwise, an attacker who sees enough ECDSA signatures can ultimately recover the SK[^BH19e].

{: .info}
**Security:** Not only is $(r,s)$ a valid signature but so is $(r,-s)$ which introduces _malleability attacks_.
\
_Historical aside:_ Such attacks may have played a small role in the MtGox attacks[^DW14], where \$620 million worth of Bitcoin disappeared.
However, the predominant theory is that there is other funny business that accounts for most of the stolen funds[^mtgox].

$\textcolor{grey}{\text{// assumes}\ \pk\in \Gr}\ \textcolor{grey}{\text{of prime order}}$\
$\mathsf{ECDSA}$.$\mathsf{Verify}(m, \pk, \sigma) \rightarrow \\{0,1\\}$:
 - $(r,s)\gets \sigma$
 - **assert** $r \in \Zp\setminus\\{0\\}$
 - **assert** $s \in \Zp\setminus\\{0\\}$
 - **assert** $r \equals f\left(\left(g^{H(m)} \pk^r\right)^{s^{-1}}\right)$

{: .note}
In practice, computing this as a size-2 multiexp $g^{s^{-1}H(m)}\pk^{s^{-1} r}$ will be faster!

#### Saving a field inversion during verification

Verification computes a field inversion $s^{-1} \bmod p$, which can be expensive.
However, observe that if we changed signing to output $s\gets k(H(m)+\sk\cdot r)^{-1}$, then verification would just be $r\equals f((g^{H(m)} \pk^r)^s)$.

This remains secure[^i-confirmed], gives slightly faster verification, but precludes precomputing many $(k,k^{-1},R)$ tuples so as to make signing faster. 
Instead, a field inversion $(H(m)+\sk\cdot r)^{-1}$ must be computed during signing. 
And, since this inversion now depends on the message $m$, precomputation is no longer possible. 

Nonetheless, this is a great trade-off in applications where fast verification time is crucial, such as blockchain TXN signature verification.
(Unfortunately, this modification is no longer standard ECDSA, so it will never see wide adoption...)

{: .note}
Interestingly, avoiding this modular inversion during signing could have obviated a recent side-channel attack on ECDSA signing[^eea-side-channel]\: _"This vulnerability lies in the ECDSA ephemeral key (or nonce) modular inversion. [...] More precisely, in the Infineon implementation of the Extended Euclidean Algorithm (EEA for short). To our knowledge, this is the first time an implementation of the EEA is shown to be vulnerable to side-channel analysis."_

### Correctness

We show that correctly-computed signatures verify (i.e., "correctness") by expanding the verification equation:
\begin{align}
\label{eq:ecdsa-verify}
r &\equals f\left(\left(g^{H(m)} \pk^r\right)^{s^{-1}}\right)\Leftrightarrow\\\\\
r &\equals f\left(\left(g^{H(m)} g^{\sk \cdot r}\right)^{s^{-1}}\right)\Leftrightarrow\\\\\
r &\equals f\left(\left(g^{H(m) + \sk \cdot r}\right)^{s^{-1}}\right)\Leftrightarrow\\\\\
r &\equals f\left(g^{s^{-1}(H(m) + \sk \cdot r)}\right)\Leftrightarrow\\\\\
r &\equals f\left(g^{\left(k^{-1}(H(m) + \sk\cdot r)\right)^{-1}(H(m) + \sk \cdot r)}\right)\Leftrightarrow\\\\\
r &\equals f\left(g^{k(H(m) + \sk\cdot r)^{-1}(H(m) + \sk \cdot r)}\right)\Leftrightarrow\\\\\
r &\equals f\left(g^k\right)\Leftrightarrow\\\\\
r &= f\left(R\right)
\end{align}

## Pubkey recovery algorithm

ECDSA, together with some variants of [Schnorr](/2024/05/31/Schnorr-signatures.html#pubkey-recovery), are one of the few schemes that support a **pubkey recovery** algorithm: i.e., an algorithm that, given a signature $\sigma$ on a message $m$, returns (a set of) public key(s) under which $\sigma$ verifies on $m$.

Pubkey recovery is actually used in cryptocurrencies like Ethereum and Bitcoin, where the verifiers (i.e., the miners/validators) do not have the PK of the account, but only its hash $h$.
Specifically, the verifiers:
1. Receive only $(\sigma,m)$
2. Use the pubkey recovery algorithm to recover a set of PKs $S=\\{\pk_1,\ldots,\pk_\ell\\}$ under which $(\sigma,m)$ verify 
3. Check whether there exists a $\pk_i \in S$ such that $h=H(\pk_i)$. (This step is crucial.)
4. If so, they can consider the message $m$ (typically a TXN hash) as validly-signed under the PK $\pk_i$ hashed inside the address $h$[^P2PKH].

Let's try to figure out how pubkey recovery might work.
We know from the verification algorithm in Eq. \ref{eq:ecdsa-verify} that, given a correctly-computed ECDSA signature $(r,s)$, where $r=f(R)$, we have:
\begin{align}
f(R) &= f\left(\left(g^{H(m)} \pk^r\right)^{s^{-1}}\right)
\end{align}

Assume for a second that the function $f$ were [injective](https://en.wikipedia.org/wiki/Injective_function), which it is not. Then, the equation above would imply:
\begin{align}
R &= \left(g^{H(m)} \pk^r\right)^{s^{-1}}\Leftrightarrow\\\\\
R^s &= g^{H(m)} \pk^r\Leftrightarrow\\\\\
R^s / g^{H(m)} &= \pk^r\Leftrightarrow\\\\\
\label{eq:pubkey-recovery}
\left(R^s / g^{H(m)}\right)^{(r^{-1})} &= \pk\\\\\
\end{align}

This means that, for a correctly-computed $(r,s)$, we could invert $R = f^{-1}(r)$ and then extract the PK as per Eq. \ref{eq:pubkey-recovery}.

However, things are not so simple.

**Challenge 1:** First, as stated above, $f$ is **not** injective.
A little elliptic curve background is required to understand why.
The _tl;dr_ is that, given an $x$-coordinate of a point on an elliptic curve $E_{a,b}(\Fq): y^2 = x^3 + ax + b$, there are two possible $y$-coordinates that satisfy the equation: i.e., $y=\pm\sqrt{x^3 + ax+b}$. 

As a consequence, given the $x$-coordinate $x$ of $R$, we can extract two points $R$ and $R'$ such that $r=f(R)=f(R')$.
Plugging both of these possibilites for $R$ in Eq. \ref{eq:pubkey-recovery} now yields **two possible public keys**.
This is fine: it just means the signature verifies against either one.

**Challenge 2:** Above, we assumed we have the $x$-coordinate $x$ of $R$.
But the ECDSA signature does not include $x \in \Fq$; it only includes $\bar{x} \bmod p = r\in \Zp$, where $\bar{x}$ is the representation $x$ as an integer $\in [0,q)$. 
(Recall that $p$ is the order of the elliptic curve with base field $\Fq$.)
By Hasse's theorem[^hasse], we know that:

$$(q + 1) - 2\sqrt{q} \le p \le (q+1) + 2\sqrt{q}$$

So, it could be that $p \ge q$ or that $p < q$.

**Case 1:** If $p\ge q$, then given $r$, we can recover $x$ since the $\bmod p$ operation does not truncate $x$ when computing $r$.

**Case 2:** But, if $p < q$, it could be that $\bar{x} \in [0,q)$ was truncated when computing $r=\bar{x} \bmod p$ (i.e., it could be that $\bar{x} \ge p$).
So, this means we have two possible x-coordinates[^bitcoin-stex]:
\begin{align}
x_1 &= \bar{r} \in [0,q)\\\\\
x_2 &= (\bar{r} + p) \bmod q
\end{align}
<!-- 
Only need to do (\bar{r} + p) \bmod q, because |p - q| < 2\sqrt{q} 
-->
Then, each $x_i$ will have two possible y-coordinates: $y_i=\pm\sqrt{x_i^3 + ax_i + b}$.
And as a result, there are now four possible $R$'s to recover:
\begin{align}
R_1 &= (x_1, y_1)\\\\\
R_1' &= (x_1, -y_1)\\\\\
R_2 &= (x_2, y_2)\\\\\
R_2' &= (x_2, -y_2)\\\\\
\end{align}
To avoid the need to brute force all possible $R$ values, some systems like Ethereum, include a 2-bit **hint** or **recovery ID** $v$ next to an ECDSA signature $(r,s)$.
This $v$ indicates to a verifier which one of the 4 values above should be computed as the actual $R$, saving precious signature verification computation. 
This is why, in online folklore, you will find ECDSA signatures described as a triple $(r,s,v)$.

## Batch verification

Recall from how ECDSA verification works in Eq. \ref{eq:ecdsa-verify} that a verifier must apply the conversion function $f$ over some computation and match against $r$:
\begin{align}
r &\equals f\left(\left(g^{H(m)} \pk^r\right)^{s^{-1}}\right)\Leftrightarrow
\end{align}
Unfortunately, the conversion function is not amenable to batching.
(Feel free to try!)
To address this, Cheon and Yi[^CY07] introduced **modified ECDSA**, a.k.a., **ECDSA$^\*$**.

The only difference is that, instead of including $r=f(R)$, modified ECDSA includes $R$ as part of the signature.
Therefore, signature verification no longer goes through the conversion function:
\begin{align}
\label{eq:modified-ecdsa-verify}
R \equals \left(g^{H(m)} \pk^r\right)^{s^{-1}}
\end{align}
As a result, a batch of signatures $$(R_i, s_i)_{i\in[n]}$$ for messages $$m_i$$ and PKs $$\pk_i$$ can be batch-verified using random coefficients $$\alpha_i\randget\Zp$$:
\begin{align}
\prod_{i\in[n]} R_i^{\alpha_i} \equals \prod_{i\in[n]} \left(g^{H(m_i)} \pk_i^{r_i}\right)^{s_i^{-1}\alpha_i}\Leftrightarrow\\\\\
1 \equals \prod_{i\in[n]} \left\[R_i^{-\alpha_i} \left(g^{H(m_i)} \pk_i^{r_i}\right)^{s_i^{-1}\alpha_i}\right\]\Leftrightarrow\\\\\
\label{eq:batch-verification}
1 \equals \prod_{i\in[n]} \left(R_i^{-\alpha_i} g^{H(m_i)\cdot s_i^{-1}\cdot \alpha_i} \pk^{r_i \cdot s_i^{-1}\cdot \alpha_i}\right)
\end{align}

We describe the modified ECDSA scheme that supports batch verification below. 
Changes from normal ECDSA are highlighted in $\textcolor{red}{\text{red}}$.

$\mathsf{ECDSA^\*}$.$\mathsf{Sign}(m, \sk) \rightarrow \sigma\in(\textcolor{red}{\Gr},\textcolor{red}{\Zp})$:
 1. $k \randget \Zp\setminus\\{0\\}\ \textcolor{grey}{\text{// 0 is excluded as a valid nonce}}$
 1. $R\gets g^k$ 
 1. $r\gets f(R)$ 
     - **if** $r\equals 0$, go back to **step 1**
 1. $s \gets k^{-1}(H(m) + \sk\cdot r) \bmod p$ 
     - **if** $s\equals 0$, go back to **step 1**
 1. $\sigma\gets (\textcolor{red}{R},s)\ \textcolor{grey}{\text{// no longer returns}}\ r$

$\textcolor{grey}{\text{// assumes}\ \pk\in \Gr}\ \textcolor{grey}{\text{of prime order}}$\
$\mathsf{ECDSA^\*}$.$\mathsf{Verify}(m, \pk, \sigma) \rightarrow \\{0,1\\}$:
 - $(\textcolor{red}{R},s)\gets \sigma$
 - assert $R$ is in the prime-order subgroup $\Gr$
 - **assert** $s \in \Zp\setminus\\{0\\}$
 - **assert** $\textcolor{red}{R \equals \left(g^{H(m)} \pk^r\right)^{s^{-1}}}\ \textcolor{grey}{\text{// no longer using the conversion function}}\ f$


$\textcolor{grey}{\text{// assumes}\ \pk_i\in \Gr}\ \textcolor{grey}{\text{of prime order}}$\
$\mathsf{ECDSA^\*}$.$\mathsf{BatchVerify}((m_i, \pk_i, \sigma_i)_{i\in [n]}) \rightarrow \\{0,1\\}$:
 - $(R_i,s_i)\gets \sigma_i,\forall i\in [n]\ \textcolor{grey}{\text{// implicitly asserts}\ R_i \in\Gr\ \text{of prime order}}$
 - **assert** $s_i \in \Zp\setminus\\{0\\},\forall i \in S$
 - $\alpha_i \randget \Zp,\forall i\in [n]$
 - assert $1 \equals \prod_{i\in[n]} \left(R_i^{-\alpha_i} g^{H(m_i)\cdot s_i^{-1}\cdot \alpha_i} \pk^{r_i \cdot s_i^{-1}\cdot \alpha_i}\right)$

{: .note}
The most efficient implementation would use **batch inversion**[^inv-tweet] to compute all the $s_i^{-1}$'s.
Then, it would compute all the exponents in the right-hand side in Eq. \ref{eq:batch-verification}.
Finally, it would compute this right-hand side via a size-$3n$ multi-exponentiation.

## Implementation caveats

Implementing ECDSA securely and efficiently can be tricky:

 1. Must remember to verify that $r$ and $s$ are not $0$
 2. If not using prime-order groups, prime-order subgroup membership checks must be performed on...
     - ...the PKs passed into the verification equation
     - ...the $R$-component of [modified ECDSA](#batch-verification) signatures
 3. Should aim to use efficient inversion algorithms[^inv-tweet] for $s^{-1}$ (e.g., EEA-based, Lehmer) 
 1. ECDSA, like [Schnorr](/2024/05/31/Schnorr-signatures.html), is broken if the **nonce $k$ is reused**. Generally, they are both very **fragile** if the nonce $k$ is biased[^BH19e].
    + Even small amounts of bias in the nonce $k$ can be used to recover the SK given enough signatures.
    - Deterministic signing can mitigate this in both schemes.

## Why you should avoid ECDSA

**Hot take 🌶️:** There is **no** good reason to ever use ECDSA (except for legacy compatibility). 

As far as I can tell, [Schnorr signatures](/2024/05/31/Schnorr-signatures.html) should always be preferred over it:
 - Schnorr is _slightly_ faster, especially in the batched setting (no field inversions)
 - Schnorr admits a reasonably-efficient $t$-out-of-$n$ threshold signing protocol
 - Schnorr has a simpler pubkey recovery (no recovery hints needed)
 - Schnorr has an arguably-cleaner security reduction
 - Schnorr (not EdDSA nor Ed25519) supports batch verification out-of-the-box

Other disadvantages of ECDSA:

 1. ECDSA is **inefficient as a $t$-out-of-$n$ threshold signature** scheme
 1. (Standardized) ECDSA does not support batched verification (although [it can be modified to](#batch-verification))
 1. ECDSA does **not** have a **"clean" security reduction** to a standard assumption
    - Typically, ECDSA security reductions must make assumptions about the [conversion function](#the-ecdsa-conversion-problem)
    - ...or work in the generic group model (GGM)
    - ...or introduce strange assumptions like the _semi-discrete logarithm (SDLP)_ problem
    + In fact, algebraic security reduction for ECDSA _"can only exist if the security reduction is allowed to program the conversion function"_[^HK23e]
    - For the latest security analysis, see recent works by Eike Kiltz[^FKP16]$^,$[^HK23e].
 1. ECDSA is often used over NIST curves. It doesn't have to be, but it is. Some folks suspect these curves could be backdoored[^safe-curves].

{: .note}
Although ECDSA can be very fragile in the face of side-channels (e.g., see extracting ECDSA keys from Yubikeys[^eea-side-channel]), it is not clear to what extent other schemes would fare better. For example, both [Schnorr](/2024/05/31/Schnorr-signatures.html) and BLS[^BLS01] do exponentiations with secrets.

## Conclusion

Despite my strong bias against ECDSA, I still find it to be a cool signature scheme:

 1. (I believe?) ECDSA was the first **wide-deployment** of elliptic-curve cryptography
 1. ECDSA does not use the Fiat-Shamir transform[^FS87]
 1. ElGamal signatures (and thus [EC]DSA) are one of the few paradigms for signature schemes in the prime-order group setting without pairings
     + Besides Fiat-Shamir-style signatures from $\Sigma$-protocols (e.g., Schnorr[^Schn89], Chaum-Pedersen[^CP92], Okamoto[^Okam93]), what else is there?
 1. ECDSA showcased the utility of pubkey recovery algorithms in cryptocurrencies like Bitcoin and Ethereum

### Future work

Other items I hope to address in the future:

 - The necessity of random oracles in ElGamal/DSA to prevent [existential forgeries](https://en.wikipedia.org/wiki/ElGamal_signature_scheme#Existential_forgery) (also [here](https://crypto.stackexchange.com/questions/35684/el-gamal-existential-forgery-using-pointcheval-stern-signature-algorithm))
 - I hope to write down a reasonable proof of ECDSA's EUF-CMA security.
 - Other [summaries of why ECDSA is very feeble](https://blog.trailofbits.com/2020/06/11/ecdsa-handle-with-care/).
 - Look into [Shamir trick stuff](https://crypto.stackexchange.com/questions/47627/goofs-that-could-creep-in-ecdsa-signature-verification)
 - Address implementations checking that $R$ is not the identity
 - An unecessary check that [the PK is not the identity](https://crypto.stackexchange.com/questions/74354/ecdsa-signature-verification-checks) during verification
 - Incorporate insights from [SEC 1: Elliptic curve cryptography](https://www.secg.org/sec1-v2.pdf)
 - [Batched ECDSA verification inside circom for zkSNARKs](https://0xparc.org/blog/batch-ecdsa)

## References

For cited works, see below 👇👇

[^bitcoin-stex]: See [this comment](https://bitcoin.stackexchange.com/questions/38351/ecdsa-v-r-s-what-is-v/38909#comment46061_38909) on Bitcoin Stack Exchange for a similar explanation.
[^certicom-ecc]: [Elliptic Curve Cryptography (ECC)](https://www.certicom.com/content/certicom/en/ecc.html), Certicom
[^dss]: NIST's [call for digital signature schemes to be standardized](https://archive.epic.org/crypto/dss/dss_fr_notice_1991.html)
[^ec-drbg]: [Dual_EC_DRBG](https://en.wikipedia.org/wiki/Dual_EC_DRBG), Wikipedia
[^eea-side-channel]: [EUCLEAK](https://ninjalab.io/eucleak/), by NinjaLab
[^elgamal-signing]: If $r=g^k$, then Eq. \ref{eq:elgamal-intuition} becomes $g^m = g^{\sk \cdot r} g^{k \cdot s} \bmod p$. If we look "in the exponent", we get $m \equiv \sk \cdot r + k\cdot s \pmod{p-1}$. Therefore, we can solve for $s$ as per Eq. \ref{eq:elgamal-sig-s}, since $\gcd(k, p-1) = 1$.
[^fgrieu-pubkey-recovery]: [ECDSA public key recovery is discovered by whom?](https://crypto.stackexchange.com/questions/60958/ecdsa-public-key-recovery-is-discovered-by-whom)
[^foia]: [New NIST/NSA relevelations](https://web.archive.org/web/20200229145033/https://catless.ncl.ac.uk/Risks/14/59#subj7), Dave Banisar, 1993
[^hasse]: [Hasse's theorem on elliptic curves](https://en.wikipedia.org/wiki/Hasse%27s_theorem_on_elliptic_curves), Wikipedia
[^i-confirmed]: See my [StackExchange post](https://crypto.stackexchange.com/questions/113745/ecdsa-without-field-inversion-during-verification/113749#113749) double-checking the sanity of avoiding the field inversion and asking why it hasn't been done before.
[^inv-tweet]: [Today, I f***** around and \[re\]found out how slow inverting a field elements is](https://x.com/alinush407/status/1836912804902682625), Alin Tomescu, 2024
[^modified-ecda]: [This](https://crypto.stackexchange.com/questions/53025/what-is-customizable-in-ecdsa-signature-and-verification) StackExchange post suggests that signing as $(g^k, k^{-1}(H(m)+\sk\cdot r))$ can be useful when combining ECDSA with other algorithms.
[^mtgox]: Citing from [DW14][^DW14]: _"In combination with the above mentioned success rate of malleability attacks we conclude that overall malleability attacks did not have any substantial inﬂuence in the loss of bitcoins incurred by MtGox."_
[^P2PKH]: [ECDSA verification, P2PKH uncompressed address](https://en.bitcoin.it/wiki/Message_signing#ECDSA_verification.2C_P2PKH_uncompressed_address)
[^safe-curves]: [SafeCurves: choosing safe curves for elliptic-curve cryptography](https://safecurves.cr.yp.to/rigid.html), Daniel J. Bernstein, 2013
[^vanstone]: [Scott Vanstone](https://en.wikipedia.org/wiki/Scott_Vanstone), Wikipedia

{% include refs.md %}
