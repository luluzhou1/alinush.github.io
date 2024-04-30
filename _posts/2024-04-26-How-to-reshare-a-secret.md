---
tags: cryptography, secret-sharing
title: How to reshare a secret
#date: 2020-11-05 20:45:59
published: true
#sidebar:
#    nav: cryptomat
---

{: .info}
**tl;dr:** A $t$-out-of-$n$ sharing of $s$ can be reshared as a $t'$-out-of-$n'$. 
How?
Each _old_ player $t'$-out-of-$n'$ reshares their share with the **new** players. 
Let $H$ denote an agreed-upon set of $\ge t$ _old_ players who (re)shared correctly. 
Then, each **new** player's $t'$-out-of-$n'$ share of $s$ will be the Lagrange interpolation (w.r.t. $H$) across all the shares received from the old players.

<!--more-->

<p hidden>$$
\def\Adv{\mathcal{A}}
\def\Badv{\mathcal{B}}
\def\vect#1{\mathbf{#1}}
$$</p>

## Preliminaries: How to share a secret

This article assumes familiarity with _Shamir secret sharing_[^Shamir79], a technique that allows a **dealer** to "split up" a **secret** $s$ amongst $n$ **players** such that any subset of size $\ge t$ can reconstruct $s$ yet no subset of size $<t$ learns _anything_ about the secret.

### Shamir secret sharing
Recall that a secret ${\color{green}s}\in \Zp$ is $t$-out-of-$n$ secret-shared as follows:

 1. The **dealer** encodes $s$ as the 0th coefficient in a random degree-$(t-1)$ polynomial $\color{green}{f(X)}$:
\begin{align}
    f(X) &= s + \sum_{k=1}^{t-1} f_k X^k,\ \text{where each}\ f_k\randget \Zp
\end{align}

 2. The dealer gives each player $i\in [n]$, their **share** $s_i$ of $s$ as:
\begin{align}
\color{green}{s_i} &= f(i)\\\\\
    &= s + \sum_{k=1}^{t-1} f_k \cdot i^k
\end{align}

 3. The shares $[s_1, s_2, \ldots, s_n]$ define the $t$-out-of-$n$ **sharing** of $s$.

### Lagrange polynomials
Recall the definition of a [Lagrange polynomial](/2022/07/28/lagrange-interpolation.html) w.r.t. to a set of evaluation points $T$.
\begin{align}
    \forall i\in[n],
    \color{green}{\lagr_i(X)} &= \prod_{k\in T, k\ne i} \frac{X - k}{i - k}
\end{align}
The relevant properties of $L_i^T(X)$ are that:
\begin{align}
    L_i(i) &= 1,\forall i \in T\\\\\
    L_i(j) &= 0,\forall i, j\in T, i\ne j\\\\\
\end{align}

### Shamir secret reconstruction
    
Any subset $T\subseteq[n]$ of $t$ or more players can reconstruct $s$ by combining their shares as follows:
\begin{align}
    \sum_{i\in T} \lagr_i^T(0) s_i &= \sum_{i\in T}\lagr_i^T(0) f(i) = f(0) = s\\\\\
\end{align}

## How to reshare a secret

Suppose the _old_ players, who have a $t$-out-of-$n$ sharing of $s$, want to **reshare** s with a set of $\color{green}{n'}$ **new** players such that any $\color{green}{t'}$ players can reconstruct $s$.

In other words, they want to $t'$-out-of-$n'$ reshare $s$.

Importantly, they want to do this without leaking $s$ or any info about the current $t$-out-of-$n$ sharing of $s$.
A technique for this, whose origins are (likely?) in the BGW paper[^BGW88], is described by Cachin et al.[^CKLS02] and involves four steps:

1. Each _old_ player $i$ first _"shares their share"_ with the **new** $n'$ players: i.e., randomly sample a degree-$(t'-1)$ polynomial $\color{green}{r_i(X)}$ that shares their $s_i$:
\begin{align}
\color{green}{r_i(X)} &= s_i +  \sum_{k=1}^{t'-1} {\color{green}r_{i,k}} X^k,\ \text{where each}\ r_{i,k}\randget \Zp\\
\end{align}

2. Let ${\color{green}z_{i,j}}$ denote the share of $s_i$ for player $j\in[n']$.
\begin{align}
{\color{green}z_{i,j}} = r_i(j)
\end{align}
Then, each _old_ player $i$ will send $z_{i,j}$ to each **new** player $j\in [n']$.

3. The **new** players agree[^consensus] on a set $\color{green}{H}$ of _old_ players who correctly-shared their share $s_i$.

4. Each **new** player $j\in [n']$ interpolates their share $\color{green}{z_j}$ of $s$ as:
\begin{align}
    \label{eq:newshare}
    {\color{green}z_j} 
        &= \sum_{i\in H} \lagr_i^H(0) z_{i,j}\\\\\
        &= \sum_{i\in H} \lagr_i^H(0) r_i(j)
\end{align}

And voilà: **SUCH A BEAUTIFUL, SIMPLE PROTOCOL** for secret **re**sharing.

### Why does this work?

It's easy to see why if we reason about the underlying polynomial defined by the **new** players' shares $z_j$.
Specifically, the degree-$(t'-1)$ polynomial $r(X)$ where $r(0) = s$:
\begin{align}
r(x) &= \sum_{i\in H} \lagr_i^H(0) r_i(X)\\\\\
     &= \sum_{i\in H} \lagr_i^H(0) \left(s_i + \sum_{k=1}^{t'-1} r_{i,k} \cdot X^k\right)\\\\\
     &= \left(\sum_{i\in H} \lagr_i^H(0) f(i)\right) + \left(\sum_{i\in H}\lagr_i^H(0) \left(\sum_{k=1}^{t'-1} r_{i,k} \cdot X^k\right)\right)\\\\\
     &= s + \sum_{i\in H}\lagr_i^H(0) \left(\sum_{k=1}^{t'-1} r_{i,k} \cdot X^k\right)\\\\\
    &\stackrel{\mathsf{def}}{=} s + \sum_{k=1}^{t'-1} {\color{green}r_k} X^k
\end{align}

In other words, $[s, r_1, r_2,\ldots,r_{t'-1}]$ are the coefficients of the polynomial obtained from the linear combination of the $r_i(X)$'s by the Lagrange coefficients $\lagr_i^H(0)$.

In more detail:
\begin{align}
r(x) &= s + \left(\begin{matrix}
         &\lagr_{i_1}^H(0) \left(\sum_{k=1}^{t'-1} r_{i_1,k} \cdot X^k\right) + {}\\\\\
         &\lagr_{i_2}^H(0) \left(\sum_{k=1}^{t'-1} r_{i_2,k} \cdot X^k\right) + {}\\\\\
         &\ldots\\\\\
         &\lagr_{i_{|H|}}^H(0) \left(\sum_{k=1}^{t'-1} r_{i_{|H|},k} \cdot X^k\right)\\\\\
     \end{matrix}\right)
\end{align}

Let ${\color{green}c_{i_j, k}} \stackrel{\mathsf{def}}{=} \lagr_{i_j}^H(0) \cdot r_{i_j, k}$.
Then, we can rewrite the above as:
\begin{align}
r(x) &= s + \left(\begin{matrix}
         &\sum_{k=1}^{t'-1} c_{i_1,k} \cdot X^k + {}\\\\\
         &\sum_{k=1}^{t'-1} c_{i_2,k} \cdot X^k + {}\\\\\
         &\ldots\\\\\
         &\sum_{k=1}^{t'-1} c_{i_{|H|},k} \cdot X^k\\\\\
     \end{matrix}\right)
\end{align}
Let ${\color{green}r_k}\stackrel{\mathsf{def}}{=} \sum_{i_j \in H} c_{i_j, k}$.
Then, we can rewrite the above as:
\begin{align}
r(x) &\stackrel{\mathsf{def}}{=} s + \sum_{k=1}^{t'-1} r_k X^k
\end{align}

And, as we saw in Equation \ref{eq:newshare} above, any **new** player $j\in[n']$ can get their share of $r(X)$ via:
\begin{align}
z_j
    &= \sum_{i\in H} \lagr_i^H(0) r_i(j)\\\\\
    &= r(j)
\end{align}

## Acknowledgements

Big thanks to [Benny Pinkas](https://twitter.com/bennypinkas) for pointing me to the BGW paper[^BGW88] and for pointing out subtleties in what it means for an old player to correctly share their share.

[^consensus]: This step is non-trivial and is where most protocols work hard to achieve efficiency. For example, see [^CKLS02]. Publicly-verifiable secret sharing (PVSS) on a public bulletin board such as a blockchain is a simple (albeit naive) way of achieving this: there will be $n$ PVSS transcripts, one for each-reshared $s_i$, and everyone can agree on the set $H$ of valid transcripts.

{% include refs.md %}
