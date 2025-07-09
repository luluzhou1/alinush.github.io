---
tags:
 - kzg
 - hyrax
 - kzh
 - polynomial commitments
 - tensors
title: KZH polynomial commitments
#date: 2020-11-05 20:45:59
#published: false
permalink: kzh
sidebar:
    nav: cryptomat
#article_header:
#  type: cover
#  image:
#    src: /pictures/.jpg
---

{: .info}
**tl;dr:** KZG + Hyrax[^WTSplus18] = KZH[^KZHB25e]. This name makes me happy: not only it stands on its own but it also coincides with the first three authors' initials!

<!--more-->

<!-- Here you can define LaTeX macros -->
<div style="display: none;">$
\def\kzh#1{\mathsf{KZH}_{#1}}
\def\kzhTwo{\kzh{2}}
\def\kzhK{\kzh{k}}
\def\kzhSetup#1{\kzh{#1}.\mathsf{Setup}}
\def\kzhOpen#1{\kzh{#1}.\mathsf{Open}}
\def\tobin#1{\langle #1 \rangle}
\def\vect#1{\boldsymbol{#1}}
\def\btau{\vect{\tau}}
\def\prk{\mathsf{prk}}
\def\G{\vect{G}}
\def\A{\vect{A}}
\def\V{\vect{V}}
\def\H{\mat{H}}
%\def\?{\vect{?}}
% - Let $\tobin{i}_s$ denote the $s$-bit binary representation of $i$
$</div> <!-- $ -->

{% include mle.md %}

## Preliminaries

 - $[m]=\\{1,2,3,\ldots,m\\}$
 - $[m)=\\{0,1,2,\ldots,m-1\\}$
 - $\bin^s$ denotes the boolean hypercube of size $2^s$.
 - Let $\F$ denote a finite field of prime order $p$
 - Let $\Gr_1,\Gr_2,\Gr_T$ denote cyclic groups of prime order $p$ with a bilinear map $e : \Gr_1\times\Gr_2\rightarrow\Gr_T$ where computing discrete logs is hard
    + We use additive group notation
 - Denote $\mle{s}$ as the space of all multilinear extensions (MLEs) $f(X_1,\ldots,X_s)$ of size $2^s$ with entries in $\F$
    - We also use $\mle{s_1,s_2,\ldots,s_\ell} \bydef \mle{\sum_{i\in[\ell]} s_i}$ 
 - Denote $i$'s binary representation as $\vect{i} = (i_0, i_1, \ldots, i_{s-1})\in \bin^s$, s.t. $i=\sum_{k=0}^{s-1} 2^k \cdot i_k$
    - We often naturally interchange between these two, when it is clear from context
 - $(v_0, v_2, \ldots, v_{n-1})^\top$ denotes the transpose of a row vector
 - We typically use bolded variables to indicate vectors and matrices
    - e.g., a matrix $\mat{A}$ consists of rows $\mat{A}\_i,\forall i\in[n)$, where each row $\mat{A}\_i$ consists of entries $A_{i,j},\forall j\in[m)$
    - e.g., vectors $\V$ are typically italicized while matrices $\mat{M}$ are not
 - We use $\vect{a}\cdot G\bydef (a_0\cdot G,a_1\cdot G,\ldots, a_{n-1}\cdot G)$
 - We use $a\cdot \G\bydef (a\cdot G_0,a\cdot G_1,\ldots, a\cdot G_{n-1})$
 - We use $\langle \vect{a}, \G\rangle \bydef \sum_{i\in[n)} a_i\cdot G_i$

## $\mathsf{KZH}_2$ construction

This construction can be parameterized to commit to any MLE 
$f(\X,\Y)\in \mle{\term{\nu},\term{\mu}}$
representing a matrix of $\term{n} = 2^\nu$ rows and $\term{m}=2^\mu$ columns, where
$\X\in \bin^\nu$ indicates the row and $\Y\in\bin^\mu$ indicates the column.

### $\mathsf{KZH}_2.\mathsf{Setup}(1^\lambda, \nu,\mu) \rightarrow (\mathsf{vk},\mathsf{prk})$[^N]
 
Notation:
 - $n \gets 2^\nu$ denotes the # of matrix rows
 - $m \gets 2^\mu$ denotes the # of matrix columns
 - $N = n\cdot m\bydef 2^{\nu + \mu}$ denotes the total # of entries in the matrix

Pick trapdoors and generators:
 - $\term{\alpha}\randget\F$
 - $\term{\btau} \bydef (\tau_0, \tau_1,\ldots,\tau_{n-1})\randget \F^n$
 - $\term{\G}\bydef(G_0,\ldots, G_{m-1})\randget \Gr_1^m$
 - $\term{V}\randget \Gr_2$

Compute $\H\in\Gr_1^{n \times m}$:
\begin{align}
\forall i\in[n),j\in[m),
H\_{i,j} 
    &\gets \tau\_i \cdot G_j\\\\\
\forall i\in[n),
\H\_i
    &\gets \tau_i\cdot \G
    %\\\\\
    \bydef (\tau_i \cdot G_0,\tau_i\cdot G_1,\dots,\tau_i\cdot G_{m-1})\\\\\
    %&\bydef (H\_{i,0},\ldots,H_{i,m-1})\\\\\
\term{\H}
    &\bydef \begin{pmatrix}
        \H\_0\\\\\ 
        \H\_1\\\\\ 
        \vdots\\\\\
        \H\_{n-1}\\\\\
    \end{pmatrix}
    %\\\\\
    \bydef \begin{pmatrix}
        \tau_0 \cdot \G\\\\\
        \tau_1\cdot\G\\\\\
        \vdots\\\\\
        \tau_{n-1}\cdot\G\\\\\
    \end{pmatrix}
    \bydef\begin{pmatrix}
        \tau_0 \cdot G_0 &\tau_0 \cdot G_1 &  \dots & \tau_0\cdot G_{m-1}\\\\\
        \tau_1 \cdot G_0 &\tau_1 \cdot G_1 & \dots & \tau_1\cdot G_{m-1}\\\\\
        \vdots  &   & & \vdots\\\\\
        \tau_{n-1} \cdot G_0 & \tau_{n-1}\cdot G_1 & \dots & \tau_{n-1}\cdot G_{m-1}\\\\\
    \end{pmatrix}\\\\\
    &\bydef (\btau\cdot G_0,\btau\cdot G_1,\ldots,\btau\cdot G_{m-1})
\end{align}

Compute $\A\in\Gr_1^m$, $\V\in\Gr_2^n$ and $V'\in\Gr_2$:
\begin{align}
\term{\A}
    &\gets (\alpha\cdot\G)
    %\\\\\
    \bydef (\alpha\cdot G_0, \alpha\cdot G_1,\ldots,\alpha\cdot G_{m-1})\\\\\
    %&\bydef (A_0,\ldots,A_{m-1})\\\\\
\term{\V}
    &\gets (\btau\cdot V)
    %\\\\\
    \bydef (\tau_0\cdot V, \tau_1\cdot V,\ldots,\tau_{n-1}\cdot V)\\\\\
    %&\bydef (V_0,\ldots,V_{n-1})\\\\\
\term{V'}
    &\gets \alpha\cdot V\\\\\
\end{align}

Return the VK and proving key:

 - $\vk\gets (V',\V,\A)$
 - $\prk\gets (\vk, \H)$

{: .warning}
Interestingly, the $G_i$'s and $V$ generators are neither needed in the $\prk$ (when proving) nor in the $\vk$ (when verifying), although the KZH paper does include them.
They would indeed be useful when trying to verify correctness of the $\prk$ and $\vk$.

### $\mathsf{KZH}_2.\mathsf{Commit}(\mathsf{prk}, f(\boldsymbol{X},\boldsymbol{Y})) \rightarrow (C, \mathsf{aux})$

Parse the $\prk$ as:
\begin{align}
((V',\V, \A), \H) 
    &\parse \prk,\ \text{where:}\\\\\
\A
    &= (A\_j)\_{j\in[m)}\\\\\
\H 
    &= (H\_{i,j})\_{i\in[n),j\in[m)}
\end{align}

Compute the **full commitment** to $f$ (via 1 size-$N$ MSM):
\begin{align}
\term{C} \gets \sum_{i \in [n)} \sum_{j\in [m)} f(\i, \j)\cdot H_{i,j}\in \Gr_1
\end{align}

Compute the $n$ **row commitments** of $f$ (via $n$ size-$m$ MSMs):
\begin{align}
\term{D_i} \gets \sum_{j\in[m)} f(\i, \j) \cdot A_j\in\Gr_1
,
\forall i\in[n)
\end{align}

Set the auxiliary info to be these $n$ row commitments:
 - $\term{\aux}\gets (D_i)_{i\in[n)}\in\Gr_1^n$

### $\mathsf{KZH}_2.\mathsf{Open}(f(\boldsymbol{X},\boldsymbol{Y}), (\boldsymbol{x}, \boldsymbol{y}), z; \mathsf{aux})\rightarrow \pi$

Partially-evaluate $f\in \mle{\nu,\mu}$:
\begin{align}
\term{f_\x(\Y)} \gets f(\x, \Y) \in \mle{\mu}
\end{align}
<!--Evaluate $f(\x,\y)$:
\begin{align}
\term{z}\gets f_\x(\y) \bydef f(\x,\y)
\end{align}-->

{: .note}
When $\x\in\bin^\nu$ and $\y\in{\bin^\mu}$, the step above involves **zero work**:  $f_\x(\Y)$ is just the $x$th column in the matrix encoded by $f$.
Furthermore, $z=f(\x,\y)$ is simply the entry at location $(x,y)$ in the matrix.

{: .warning}
However, when $\x$ is not on the hypercube, computing $f_\x$ will require $O(nm)$ $\F$ multiplications (i.e., partial evaluations of $\eq$ Lagrange polynomials and a size-$n$ random-linear combination of all the row MLEs).
Then, computing $z = f_\x(\y)$ will require $O(m)$ $\F$ multiplications.

<!-- TODO: should give algorithms for evaluating the eq polynomials fast in another blog -->

Return the proof[^open]:
 - $\pi \gets (f_\x, \aux) \in \F^m \times \Gr_1^n$

### $\mathsf{KZH}_2.\mathsf{Verify}(\mathsf{vk}, C, (\boldsymbol{x}, \boldsymbol{y}), z; \pi)\rightarrow (z, \pi)$

Parse the VK and the proof:
\begin{align}
(V',\V,\A)
    &\parse \vk\\\\\
(f_\x,\aux)
    &\parse\pi\\\\\
(D_i)_{i\in[n)}
    &\parse \aux\\\\\
\end{align}

Check the row commitments are consistent with the full commitment (via size-$(n+1)$ multipairing):
\begin{align}
e(C, V') \equals \sum_{i\in[n)} e(D_i, V_i)\Leftrightarrow\\\\\
\end{align}

\begin{align}
e\left(\sum_{i\in[n)}\sum_{j\in[m)} f(\i,\j)\cdot H_{i,j}, \alpha\cdot V\right) 
    &\equals
\sum_{i\in[n)} e\left(\sum_{j\in[m)} f(\i, \j)\cdot A_i, \tau_i \cdot V\right)
\Leftrightarrow
\\\\\\
e\left(\sum_{i\in[n)}\sum_{ j\in[m)} (f(\i,\j)\cdot \tau_i) \cdot G_j, \alpha\cdot V\right) 
    &\equals
\sum_{i\in[n)} e\left(\sum_{j\in[m)} (f(\i, \j)\cdot \alpha) \cdot G_i, \tau_i \cdot V\right)
\Leftrightarrow
\\\\\\
e\left(\sum_{i\in[n)}\sum_{ j\in[m)} (f(\i,\j)\cdot \alpha\cdot \tau_i) \cdot G_j, V\right) 
    &\equals
\sum_{i\in[n)} e\left(\sum_{j\in[m)} (f(\i, \j)\cdot \alpha\cdot\tau_i) \cdot G_i, V\right)
\Leftrightarrow
\\\\\\
e\left(\sum_{i\in[n)}\sum_{ j\in[m)} (f(\i,\j)\cdot \alpha\cdot \tau_i) \cdot G_j, V\right) 
    &=
e\left(\sum_{i\in[n)} \sum_{j\in[m)} (f(\i, \j)\cdot \alpha\cdot\tau_i) \cdot G_i, V\right)
\end{align}
{: .info}

Check the auxiliary data:
\begin{align}
\sum_{j\in[m)} f_\x(\j) \cdot A_j \equals \sum_{i\in[n)}\eq(\x, \i) \cdot D_i
\end{align}

{: .todo}
Perf.
Link to $\eq$ polynomial definition.
Correctness proof.

Check $z$ against the partially-evaluated $f_\x$:
\begin{align}
z\equals f_\x(\y) 
\end{align}

### Efficient instantiation

Typically, when commiting to a size-$N$ MLE, the scheme is most-efficiently set up with $n = m = \sqrt{N} = 2^s$ via $\kzhSetup{2}(1^\lambda, s, s)$.
(Assuming $\sqrt{N}$ is a power of two, for simplicity here; otherwise, must pad.)

## Performance

{: .todo}
Describe concretely with table for $\kzhTwo$ and $\kzhK$, explaining eval proofs for hypercube and for non-hypercube points. Account for all pre-processing. Explain that $\kzh{\log_2{N}}$ yields $2\log_2{N}$-sized proofs.

## References

For cited works, see below 👇👇

{% include refs.md %}

[^N]: In the KZH paper[^KZHB25e], the setup algorithm only takes $N$ as input (but they confusingly denote it by $k$?)
[^open]: In the KZH paper[^KZHB25e], the evaluation $z$ is also included in the proof, but this is unnecessary. Furthermore, the paper's opening algorithm unnecessarily includes the proving key $\prk$ as a a parameter, even thought it does **not** use it at all.
