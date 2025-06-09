---
tags:
 - zero-knowledge proofs (ZKPs)
 - polynomials
 - interpolation
 - rank-1 constraint systems (R1CS)
title: The Spartan zkSNARK framework
#date: 2020-11-05 20:45:59
#published: false 
permalink: spartan
#sidebar:
#    nav: cryptomat
#article_header:
#  type: cover
#  image:
#    src: /pictures/.jpg
---

{: .info}
**tl;dr:** What a beautiful construction!

<!--more-->

{% include zkp.md %}
{% include mle.md %}

<!-- Here you can define LaTeX macros -->
<div style="display: none;">$
%
\def\aux{\mathsf{aux}}
\def\oracle#1{\langle #1 \rangle}
\def\prove{\mathsf{Prove}}
\def\FS{\mathcal{FS}}
\def\fsget{\stackrel{\FS}{\leftarrow}}
\def\FSo{ { \FS(\cdot) } }
%
\def\b{\boldsymbol{b}}
\def\btau{\boldsymbol{\tau}}
\def\binS{\bin^s}
\def\binN{\bin^{\log{n}}}
\def\C{\mathcal{C}}
\def\i{\boldsymbol{i}}
\def\inst{\mathbb{x}}
\def\j{\boldsymbol{j}}
\def\k{\boldsymbol{k}}
\def\r{\boldsymbol{r}}
\def\Z{\boldsymbol{Z}}
%
\def\bit{\mathsf{bit}}
\def\bits{\mathsf{bits}}
%
\def\row{\mathsf{row}}
\def\col{\mathsf{col}}
\def\val{\mathsf{val}}
\def\rowbits#1{\overrightarrow{\mathsf{row}_{#1}}}
\def\colbits#1{\overrightarrow{\mathsf{col}_{#1}}}
%
\def\dense{\mathcal{\green{D}}}
\def\sparse{\mathcal{\red{S}}}
\def\setup{\mathsf{Setup}}
\def\commit{\mathsf{Commit}}
\def\open{\mathsf{Open}}
\def\verify{\mathsf{Verify}}
$</div> <!-- $ -->

## Introduction

Spartan[^Sett19e]$^,$[^Sett20] is a framework for building zkSNARK schemes using the well-known **sumcheck protocol**[^LFKN92]$^,$[^Thal20] and a **sparse multilinear (MLE) polynomial commitment scheme (PCS)**.

Spartan is a SNARK for [R1CS](/r1cs) satisfiability.
Usually, such R1CS SNARKs are built by viewing the R1CS as a [QAP](/r1cs/#quadratic-arithmetic-programs-qaps).
Spartan doesn't really do that: it works directly with the R1CS matrices.

A consequence of this seems to be that its proving time is, at best, $\Omega(n)$ where $n$ is the maximum number of non-zero entries in one of the three R1CS matrices.
In contrast, SNARKs for QAP like [Groth16](/groth16) tend to have proving times of $\omega(\max{(N,m)})$ where $N$ is the number of R1CS constraints (i.e., number of rows in the matrix) and $m$ is the number of R1CS variables (i.e., number of columns).
For example, Groth16 pays $O(N\log N)$ FFT work and $O(M) + O(N)$ MSMs (see breakdown [here](/groth16/#prover-time)).

### Why I really like Spartan

1. Most of the prover work is delegatable, **publicly!**
1. Sumcheck-based, either multivariate or [univariate](/univariate-sumcheck)
    - $\Rightarrow$ linear-time (concretely-efficient) prover!
1. PCS-based, multilinear or univariate, depending on choice of sumcheck ☝️
1. It poses a very nice research question: _What is the most efficient PCS for sparse MLEs?_
1. For structured / repetitive / unifrom circuits, Spartan's [most expensive step](#step-71-spark-a-dense-to-sparse-mle-pcs-compiler) can be done by the verifier!

### Technical overview

(Universal) setup:
1. R1CS matrices as MLEs $\tilde{A},\tilde{B},\tilde{C}$
1. Commit to them via a sparse MLE PCS $\Rightarrow$ get a universal setup!

Proving:
1. Commit to the MLE extension $\tilde{Z}(\Y)$ of the **statement-witness vector** $z = (\stmt, 1, \witn)$ containing the statement and witness 
1. Reduce R1CS satisfiability to zerocheck on $F(\X) = \sum_\j \tilde{A}(\X,\j)\tilde{Z}(\j) \sum_\j\tilde{B}(\X,\j)\tilde{Z}(\j) - \sum_\j \tilde{C}(\X,\j)\tilde{Z}(\j)$ over boolean hypercube
1. Reduce zerocheck to 0-sumcheck on $F(\X)\eq_\btau(\X)$ where $\tau$ is a random point
1. Reduce 0-sumcheck to opening $F(\X)$ at $\X=\r_x$ for a random point $\r_x$
1. Reduce $F(\r_x)$ opening to three (batched) sumchecks on $\tilde{V}(\r_x, \Y)\tilde{Z}(\Y)$, for all R1CS matrices $V \in \\{A,B,C\\}$
    + Just swap in $\X=\r_x$ into the $F(\X)$ expression above and note that all you need are these three sums!
1. Reduce the batched sumchecks to openings under a random point $\r_y$
    - of $\tilde{Z}(\r_y)$
    - of $\tilde{V}(\r_x,\r_y)$ for all R1CS matrices $V\in\\{A,B,C\\}$ 
        - This last part is really key, because the proving cost is mostly affected by the sparse MLE PCS we use for $\tilde{V}$

## Preliminaries
 
We assume familiarity with the [multivariate sumcheck](#multivariate-sumcheck) protocol[^Thal20] and multilinear extension (MLE) polynomial commitment schemes (PCS) such as PST[^PST13e].

### Notation

 - we use $[s) \bydef \\{0,1,\ldots,s-1\\}$
 - we refer to a sumcheck that verifies a polynomial sums to 0 over the hypercube as a **0-sumcheck**
 - We assume all algorithms have oracle access to the same Fiat-Shamir transcript $\FS$
 - we typically denote the **boolean hypercube** of size $2^s$ as $\binS$

### Binary vectors

We often need to go from a number $b \in [0,2^s)$ to its binary representation as a vector $\b\in\binS$, and viceversa:
\begin{align}
\b = [b_0,\ldots,b_{s-1}],\ \text{s.t.}\ b = \sum_{i\in[s)} b_i 2^i
\end{align}

{: .note}
When, clear from context, we switch between the number $b$ and its binary vector representation $\b$.

### $\mathsf{eq}(\mathbf{X};\mathbf{b})$ Lagrange polynomials

We want to define a polynomial $\eq$ such that that:
\begin{align}
\forall \X,\b\in\binS,
\term{\eq(\X;\b)} &\bydef \begin{cases}
1,\ \text{if}\ \X = \b\\\\\
0,\ \text{if}\ \X \ne \b
\end{cases}\\\\\
\end{align}

How?
\begin{align}
\label{eq:lagrange}
\term{\eq(\X;\b)} &\bydef \prod_{i\in[s)}\left(b_i X_i + (1 - b_i) (1 - X_i)\right)\\\\\
%&\bydef \term{\eq(X_1,\ldots, X_s; b_1,\ldots,b_s)}\\\\\
&\bydef \term{\eq_\b(X_0,\ldots, X_{s-1})},\b\in\binS\\\\\
&\bydef \term{\eq_b(X_0,\ldots, X_{s-1})},b\in[2^s)\\\\\
\end{align}

<!--It is useful to note that:
\begin{align}
\eq_\b(\X) = \eq_\X(\b)
\end{align}-->

{: .note}
We use $b\in[2^s)$ and $\b\in\binS$ interchangeably, when clear from context.
We mostly use $\eq_b(\X)$ and do not explicitly include the number of variables $s$, which is clear from context.

{: .note}
<details>
<summary>
<em>👇 Why does this work? 👇</em>
</summary>
Try and evaluate $\eq(X;\b)$ at $\X = \b$ by evaluating each product term $b_i X_i + (1-b_i)(1-X_i)$ at $X_i = b_i$!
<br /><br/>

It would yield $b_i^2 + (1-b_i)^2$, which is always equal to 1 for $b_i\in\{0,1\}$.
So all product terms are 1 when $\X=\b$.
<br /><br/>

Next, try to evaluate at $X=\b'$ when $\b'\ne\b$.
In this case, there will be an index $i\in [s)$ such that $b'_i \ne b_i \Rightarrow b_i' = (1-b_i)$.
So, evaluating the $i$th product term at $(1-b_i)$ yields $b_i(1-b_i) + (1-b_i)(1-(1-b_i)) = b_i(1-b_i)+(1-b_i)b_i=2b_i(1-b_i)$ which is always 0.
Therefore, the product is zero when $\X\ne \b$.
</details>

### Multilinear extensions (MLEs)

Given a **vector** $\vec{V} = [v_0, \ldots v_{n-1}]$, where $n = 2^\ell$, it can be represented as a degree-1 multivariate polynomial with $\ell$ variables, a.k.a. a **multilinear extension (MLE)**, by interpolation via the Lagrange polynomials from above:
\begin{align}
\label{eq:mle}
\tilde{V}(\X) \bydef \sum_{i\in [n)} v_i \cdot \eq_i(\X)
\end{align}
This way, if $\i=[i_0,\ldots,i_{s-1}]$ is the binary representation of $i$, we have:
\begin{align}
\tilde{V}(\i) = v_i,\forall i \in [n)
\end{align}

Similarly, we can represent a **matrix** $(A_{i,j})_{i,j\in[m)}$ as an MLE:
\begin{align}
\label{eq:mle-matrix}
\tilde{A}(\X,\Y) \bydef \sum\_{i\in [m),j\in[m)} A\_{i,j} \cdot \eq\_i(\X)\eq\_j(\Y)
\end{align}
This way, we similarly have:
\begin{align}
\tilde{A}(\i,\j) = A\_{i,j},\forall i,j \in [n)
\end{align}

### Dense MLE PCS

Spartan uses a **"dense" multilinear polynomial commitment scheme** to commit to size-$2^s$ MLEs where most of the $2^s$ terms are non-zero.

#### $\dense.\setup(s)\rightarrow (\prk,\vk)$

Returns a proving key $\prk$ used to commit to multilinear polynomials over $s$ variables and to create **opening proofs** and a verification key $\vk$ used to verify openings.

#### $\dense.\commit(\prk, \tilde{F})\rightarrow c$

Computes the commitment $c$ to the multilinear polynomial $\tilde{F}(X_0,\ldots,X_{s-1})$.

#### $\dense.\open^\FSo(\prk, \tilde{F}, \boldsymbol{a}) \rightarrow (e, \pi)$

Creates an opening proof $\pi$ arguing that $\tilde{F}(\boldsymbol{a}) = e$, for $a\in \F^s$ and $e\in \F$.

#### $\dense.\verify^\FSo(\vk, c, \boldsymbol{a}, b; \pi) \rightarrow \\{0,1\\}$

Verifies that the opening proof $\pi$ correctly argues that $\tilde{F}(\boldsymbol{a}) = b$ where $\tilde{F}$ is the polynomial committed in $c$.

### Sparse MLE PCS

Let $m\bydef 2^s$.
Spartan additionally needs a **"sparse" multilinear polynomial commitment scheme** used to commit to size-$m^2$ MLEs where most of the terms in the MLE are zero.
For example, perhaps only $n = o(2^{2s})$ or $n = O(m)$ terms are non-zero.

Since Spartan needs to commit to the three [sparse R1CS matrices](/r1cs#sparsity) and evaluate their MLEs at a random point, we (restrictively) define our sparse MLE PCS algorithms to allow for exactly this!

#### $\sparse.\setup(s, n)\rightarrow (\prk,\vk)$

Sets up a scheme for committing to three multilinear polynomials over $2s$ variables, such that each polynomial interpolate an $m\times m$ (R1CS) matrix with at most $n$ non-zero entries and $m\bydef 2^s$.
Returns the proving key $\prk$ and the verification $\vk$.
(Recall matrix interpolation from [here](#multilinear-extensions-mles).)

#### $\sparse.\commit(\prk, \tilde{A}, \tilde{B}, \tilde{C})\rightarrow (c_A, c_B, c_C)$

Computes commitments to the three MLEs of matrices $A,B$ and $C$.

#### $\sparse.\open^\FSo(\prk, (\tilde{A},\tilde{B},\tilde{C}), (\x,\y)) \rightarrow (e_a, e_b, e_c; \pi)$

Creates an opening proof $\pi$ arguing all the following evaluations hold:
\begin{align}
\label{eq:sparse-mle-evals}
\tilde{A}(\x,\y) &= e_a\\\\\
\tilde{B}(\x,\y) &= e_b\\\\\
\tilde{C}(\x,\y) &= e_c\\\\\
\end{align}

#### $\sparse.\verify^\FSo(\vk, (c_A,c_B,c_C), (\x,\y); \pi) \rightarrow \\{0,1\\}$

Verifies that the opening proof $\pi$ correctly argues that the evaluations in Eq. \ref{eq:sparse-mle-evals} hold for the MLEs committed in $c_A, c_B$ and $c_C$.

### Multivariate sumcheck

#### $\SC.\prove^{\FSo}(F, T, s, d)\rightarrow (e,\pi;\r)$ 

Returns a proof $\pi$ that the claimed sum $T=\sum_{\b \in \binS} F(\b)$ reduces to verifiying that $F(\r) = e$, for some random $\r\fsget \F^s$, picked via Fiat-Shamir on the transcript so far, maintained via the $\FSo$ oracle.
Here, $s$ denotes the number of variables in $F$ and $d$ denotes the maximum degree of a variable in $F$.
Additionally, returns the evaluation claim $e$ and the randomness $\r$. (This useful in higher-level protocols that exhibit such a sumcheck proof, as these protocols have now reducing the sumcheck proving task to an opening proof that $F(\r) \equals e$.)

#### $\SC.\verify^\FSo(T, e, d; \pi)\rightarrow (b\in\\{0,1\\}; \r)$

Verifies a proof $\pi$ which argues that the claimed sum $T=\sum_{\b\in\binS} F(\b)$ is correct (for some unspecified polynomial $F$ whose variables have max-degree $d$).
This is only meaningful if one has already checked **outside this algorithm** that $F(\r) = e$, against some oracle to $F$ (e.g., a polynomial commitment).
Here, $\r\fsget\F^s$ is a random point derived via Fiat-Shamir.
Returns a success bit $b\in\\{0,1\\}$ and the randomness $\r$ used.

{: .note}
Note that all algorithm are non-interactive and assume a Fiat-Shamir[^FS87] oracle that maintains the transcript so far and can use it to derive randomness.
(A bit awkward but makes it easier to reason about securely-using sumcheck in a black-box fashion in [our later description of Spartan](#spartan-piop-framework-for-non-zk-snarks).)

### Multivariate zerocheck

We want to prove a zerocheck; i.e., that:
\begin{align}
F(\X) = 0, \forall \X\in \binS
\end{align}
There is a nice zerocheck-to-sumcheck reduction for this!
Let:
\begin{align}
\label{eq:zerocheck}
Q(\Y)\bydef \sum_{\b\in\binS} F(\b)\cdot\eq_\b(\Y)
\end{align}
(Note that $Q(\b) = F(\b),\forall \b\in\binS$.)

It can be shown that the zerocheck is equivalent to picking a random $\btau\in\F^s$ and checking:
\begin{align}
\label{eq:q-tau}
Q(\btau)
  = \sum_{\b\in\binS} F(\b)\cdot \eq_\b(\btau) &= 0\Leftrightarrow\\\\\
    \label{eq:0-sumcheck}
    \sum_{\b\in\binS} F(\b)\cdot \eq_\btau(\b) &= 0
\end{align}
In other words, it's equivalent to doing a 0-sumcheck on $F(\X)\cdot\eq_\tau(\X)$ as per Eq. \ref{eq:0-sumcheck}!

<details>
<summary>
👇 Why? Stating this as an informal theorem and proving it below... 👇
</summary>
<b>Theorem</b> (informal):
Pick $\btau$ randomly. Then, $Q(\btau) = 0 \Leftrightarrow F(\X) = 0, \forall \X \in \binS$.
(Roughly, b.c. there is a probability with which this does <b>not</b> hold. See lemma 4.3 in <a href="#fn:Sett19e">Spartan eprint</a> for a formal claim.)
<br/><br/>

<b>Proof</b> ("$\Leftarrow$"):
This follows from the definition of $Q(\cdot)$ from Eq. \ref{eq:zerocheck}, by just swapping $F(\X)$ with 0 and observing $Q$ is zero everywhere, including at $\btau$.
<br/><br/>

<b>Proof</b> [by contradiction] ("$\Rightarrow$"):
Suppose that $Q(\btau) = 0$ at a random $\tau$ yet $\exists \b\in\binS$ such that $F(\b) \ne 0$.
Then, again, from the definition of $Q(\cdot)$ from Eq. \ref{eq:zerocheck}, this implies that $Q(\Y)$ is a non-zero polynomial.
(Because one of the terms of the sum from Eq. \ref{eq:zerocheck} will have a non-zero $F(\b)$ value.)
Roughly, this contradicts the Schwartz-Zippel lemma.
</details>

### R1CS matrices

[R1CS](/r1cs) matrices $\term{A}, \term{B}, \term{C}$ are assumed to be **square** (of $\term{m}$ rows and $m$ columns) and **sparse**, with $\term{n}$ non-zero entries.

The R1CS is said to be **satisfiable** if exists a **statement-witness vector** $z\in \F^m$ such that:
\begin{align}
\label{eq:r1cs-sat}
A z \circ B z = C z
\end{align}
where:
\begin{align}
\label{eq:z}
\term{z} = (\term{\stmt}, 1, \term{\witn}) \in \mathbb{F}^{|\stmt|} \times \mathbb{F} \times \mathbb{F}^{m-|\stmt|-1}
\end{align}
with $\term{\stmt}$ being the **public statement** and $\term{\witn}$ being the **private witness**.

### R1CS instance

For convenience, an **R1CS instance** is defined as:
\begin{align}
\label{eq:r1cs-instance}
\term{\inst} = (\mathbb{F},A,B,C,\stmt,m,n)
\end{align}

{: .note}
Note that an R1CS instance $\inst$ includes the public statement $\stmt$, but not the private witness $\witn$.
It also includes the R1CS (square) matrix size $m$ and the # of non-zero entries $n$.

{: .definition}
An R1CS instance is said to be **satisfiable** iff. exists a private witness $\witn$ s.t. Eq. $\ref{eq:r1cs-sat}$ holds.
We also say the instance is **satisfied by** $\witn$.

## Spartan PIOP explanation

We focus this blog post on explaining how Spartan obtains a SNARK (no ZK) by reducing R1CS satisfiability (from Eq. \ref{eq:r1cs-sat}) to two sumchecks, a dense MLE PCS opening and a sparse MLE PCS opening.

This section describes things from the **lens of polynomial interactive oracle proofs (PIOPs)**, so it assumes interaction between the SNARK **prover** and the **verifier**.

[Later on](#spartan-piop-framework-for-non-zk-snarks), we describe Spartan as a non-interactive framework for obtaining SNARKs given sumcheck, a dense MLE PCS, and a sparse MLE PCS as abstract primitives.

Let $\term{s}=\lceil \log{m} \rceil$, where $\log$'s base is always 2.

### Step 1: MLEs of R1CS matrices, public statement and private witness

We represent the R1CS matrices $A$, $B$ and $C$ as **multilinear extensions (MLE)** $\term{\tilde{A}}, \term{\tilde{B}},\term{\tilde{C}}$, as explained in [the preliminaries](#multilinear-extensions-mles) (see Eq. \ref{eq:mle-matrix}).
<!--For example, for $A \bydef (A_{i,j})\_{i,j\in[m)}$, we define:
\begin{align}
%\term{\tilde{A}(X_1, \ldots, X_s, Y_1,\ldots,Y_s)} \bydef
\term{\tilde{A}(\X,\Y)} = \sum_{\i,\j \in \binS} A_{i,j} \cdot \eq(\X, \i)\eq(\Y,\j)
\end{align}
such that:
\begin{align}
\tilde{A}(\i,\j)=A_{i,j},\forall i,j\in[m)
\end{align}
where $i\in[m)$ is a row index, $j\in[m)$ is a column index and $\i,\j\in \binS$ are their $s$-bit binary representations, 
-->

Similarly, the **statement-witness vector** $z = (\stmt, 1, \witn) \in \mathbb{F}^m$ can be viewed as an MLE:
\begin{align}
\term{\tilde{Z}} : \binS \rightarrow \mathbb{F},\ \text{s.t.}\ \tilde{Z}(\j) = z_j, \forall j\in[m)
\end{align}

Assume (without loss of generality) that $\|\witn\| = \|\stmt\|+1$.
 
Let $\term{\tilde{W}}$ denote the size $2^{s-1}$ MLE of **only**  the private witness $\witn\in \F^{m/2}$.

The prover begins by sending the verifier an _oracle_ $\oracle{\tilde{W}}$ to $\tilde{W}$.
(Recall we are describing Spartan from the lens of PIOPs.)

Later on, it will be useful to note that, given an MLE $\term{\tilde{P}}$ for the public statement $\stmt$ and the $\oracle{\tilde{W}}$ oracle, the verifier will be able to check an opening on $\tilde{Z}$ easily because:
\begin{align}
\label{eq:Z}
\tilde{Z}(\Y) &= Y\_0 \cdot \underbrace{\term{\tilde{P}(Y_1, \ldots, Y_{s-1})}}\_{\text{MLE for}\ (\stmt,1)} + (1-Y_0)\cdot \underbrace{\term{\tilde{W}(Y_1,\ldots,Y_{s-1})}}_{\text{MLE for}\ \witn}
\end{align}

### Step 2: R1CS satisfiability $\Leftrightarrow$ deg-2 zerocheck on $F(\X)$

Then, satisfiability of an R1CS instance $A,B,C$ with public input $\stmt$ by witness $\witn$ can be expressed as:

\begin{align}
\forall\ \text{rows}\ i\in[m), \sum_{j\in[m)} A_{i,j} z_j \cdot \sum_{j\in[m)} B_{i,j} z_j - \sum_{j\in[m)} C_{i,j} z_j = 0\Leftrightarrow\\\\\
\forall\ \i\in\binS, \sum_{\j\in\binS} \tilde{A}(\i,\j) \tilde{Z}(\j) \cdot \sum_{\j\in\binS} \tilde{B}(\i,\j) \tilde{Z}(\j) - \sum_{\j\in\binS} \tilde{C}(\i,\j) \tilde{Z}(\j) = 0
%\Leftrightarrow\\\\\
%\forall \x\in \binS, \sum_{\j\in\binS} \tilde{A}(\x,\j) \tilde{Z}(\j) \cdot \sum_{\j\in\binS} \tilde{B}(\x,\j) \tilde{Z}(\j) - \sum_{\j\in\binS} \tilde{C}(\x,\j) \tilde{Z}(\j) = 0\Leftrightarrow\\\\\
\end{align}
More formally, define a degree-2 multivariate polynomial $\term{F}$ associated with the R1CS instance $\inst$:
\begin{align}
\label{eq:F}
\term{F(\X)}
&\bydef \sum_{\j\in\binS} \tilde{A}(\X,\j) \tilde{Z}(\j) \cdot \sum_{\j\in\binS} \tilde{B}(\X,\j) \tilde{Z}(\j) - \sum_{\j\in\binS} \tilde{C}(\X,\j) \tilde{Z}(\j)
\end{align}

Note that $F(\X)$ contains a product of two MLEs, so it is a degree-2 multivariate polynomial.

Then, the main result of Spartan can be stated as a theorem:

{: .theorem}
An R1CS instance $\inst$ (see Eq. \ref{eq:r1cs-instance}) is satisfied by a witness $\witn \Leftrightarrow F(\X) = 0$ for all $\X \in \binS$ (i.e., $F$ is zero on the hypercube).

### Step 3: Zerocheck on $F(\boldsymbol{X})$ $\Leftrightarrow$ deg-3 sumcheck on $F(\boldsymbol{X})\eq_\btau(\boldsymbol{X})$

[We know from above](#zero-check) that a zerocheck on $F$ can be reduced to a sumcheck on another related polynomial: <!-- $\term{G}$: -->
\begin{align}
\label{eq:G}
F(\X)\cdot \eq_\term{\btau}(\X)
\end{align}
where $\term{\btau}\randget\F^s$ is randomly picked by the verifier.
Specifically, the sumcheck will be:
\begin{align}
\label{eq:first-sumcheck}
F(\b) &= 0,\forall \b\in\binS \Leftrightarrow \sum_{\b\in\binS} F(\b)\cdot \eq_\btau(\b) = 0,\btau\randget\F^s
\end{align}

To convince the verifier, the prover will send two things.

First, an evaluation at a random point $\term{\r_x}\in \F^s$ picked by the verifier:
\begin{align}
\label{eq:ex}
\term{e_x} 
\bydef F(\term{\r_x})\cdot \eq_\btau(\term{\r_x})
\end{align}

Second, a sumcheck proof $\term{\pi_x}$, which the verifier will check against the claimed sum (i.e., 0) and the evaluation $e_x$ (as per the sumcheck protocol[^Thal20]).

{: .definition}
We refer to the sumcheck from Eq. \ref{eq:first-sumcheck} as Spartan's **first sumcheck**!

Now, thanks to sumcheck, the verifier's work is reduced to just checking that the $e_x$ evaluation from Eq. \ref{eq:ex} is correct!

While verifying the $\eq_\btau(\r_x)$ part is easy, the $F(\r_x)$ part is trickier, due to $F$'s complicated formula from Eq. \ref{eq:F}.
Fortunately, Spartan observes that this complicated formula itself is sumcheck-like!

### Step 4: From $F(\boldsymbol{r}_x)$ to degree-2 sumchecks 

<!--i.e., to $\sum_\j \tilde{V}(\r_x, \j)$ (for each R1CS matrix $V$) sumchecks plus a $\sum_\j \tilde{Z}(\j)$ sumcheck will be needed to evaluate $F$ as per Eq. \ref{eq:F}.-->


How can the prover prove the $F(\r_x)$ evaluation?

First, expand it as per Eq. \ref{eq:F} to:
\begin{align}
\label{eq:Frx}
F(\r_x)
&= \sum_{\j\in\binS} \tilde{A}(\r_x,\j) \tilde{Z}(\j) \cdot \sum_{\j\in\binS} \tilde{B}(\r_x,\j) \tilde{Z}(\j) - \sum_{\j\in\binS} \tilde{C}(\r_x,\j) \tilde{Z}(\j)\\\\\
\end{align}
If we denote the three sums above by:
\begin{align}
\label{eq:three-sumchecks}
\term{v_A} &\bydef \sum_{\j\in\binS} \tilde{A}(\r_x,\j) \tilde{Z}(\j)\\\\\
\term{v_B} &\bydef \sum_{\j\in\binS} \tilde{B}(\r_x,\j) \tilde{Z}(\j)\\\\\
\term{v_C} &\bydef \sum_{\j\in\binS} \tilde{C}(\r_x,\j) \tilde{Z}(\j)\\\\\
\end{align}

If the verifier was convinced of these, it would simply check:
\begin{align}
F(\r_x) \equals v_A \cdot v_B - v_C
\end{align}

Therefore, we have reduced verifying $F(\r_x)$ to verifying these three sumchecks from Eq. \ref{eq:three-sumchecks}!

### Step 5: From three sumchecks to four MLE openings

Luckily, the sumchecks from Eq. \ref{eq:three-sumchecks} can be batched into a single one (while remaining degree-2). 

First, the verifier picks random scalars:
\begin{align}
\term{(r_A, r_B, r_C)}\randget\F^3\\\\\
\end{align}
Second, randomly combine the $v_A, v_B, v_C$ sumchecks via these scalars:
\begin{align}
\label{eq:batched-sumcheck}
\term{T} 
&\bydef r\_A v\_A + r\_B v\_B - r\_C v\_C \\\\\
&= r\_A\left(\sum\_{\j\in\binS} \tilde{A}(\r\_x,\j) \tilde{Z}(\j)\right) +
r\_B\left(\sum\_{\j\in\binS} \tilde{B}(\r\_x,\j) \tilde{Z}(\j)\right) + 
r\_C\left(\sum\_{\j\in\binS} \tilde{C}(\r\_x,\j) \tilde{Z}(\j)\right)\\\\\
\label{eq:second-sumcheck}
&= \sum\_{\j\in\binS} \left(\underbrace{r_A \tilde{A}(\r\_x,\j) \tilde{Z}(\j) +
 r_B \tilde{B}(\r\_x,\j) \tilde{Z}(\j) + 
 r_C \tilde{C}(\r\_x,\j) \tilde{Z}(\j)}\_{\term{M\_{\r_x}(\j)}}\right)\\\\\
\end{align}
Now, the prover proves _one_ sumcheck on the $\term{M_{\r_x}(\Y)}$ polynomial from above (instead of three as per Eq. \ref{eq:three-sumchecks}).

{: .definition}
We refer to this Eq. \ref{eq:second-sumcheck} sumcheck as Spartan's **second sumcheck**!
(Recall the first one was in Eq. \ref{eq:first-sumcheck}).

As before, the prover sends a sumcheck proof $\term{\pi_y}$ that reduces verifying the claimed sum $T$ to verifying an evaluation $\term{e_y}\bydef M_{\r_x}(\term{\r_y})$ at a random $\term{\r_y}\in\F^s$ picked by the verifer.

Put differently, once the verifier verifies $\pi_y$ w.r.t. $(T,e_y)$, the verifier is only left with the task of verifying the $e_y$ opening w.r.t. to an $\oracle{M_{\r_x}}$ oracle, which can be obtained from $\oracle{\tilde{A}},\oracle{\tilde{B}},\oracle{\tilde{C}},\oracle{\tilde{Z}}$ oracles.

**This is the most difficult task in Spartan**: instantiating the PIOP model with the right polynomial commitment scheme (PCS) for the **sparse** R1CS MLEs, so as to enable efficient opening proofs for:
\begin{align}
\label{eq:r1cs-evals}
\term{a_{x,y}} \bydef \tilde{A}(\r_x,\r_y)\\\\\
\term{b_{x,y}} \bydef \tilde{B}(\r_x,\r_y)\\\\\
\term{c_{x,y}} \bydef \tilde{C}(\r_x,\r_y)\\\\\
\end{align}

After the R1CS openings above are verified, the verifier can check that $e_y \equals M(\r_x,\r_y)$ as:
\begin{align}
e_y \equals (r_A \cdot a_{x,y} + r_B \cdot b_{x,y} + r_C \cdot c_{x,y}) \cdot \tilde{Z}(\r_y)
\end{align}
Before explaining [how to get a sparse MLE PCS](#step-7-from-dense-mle-pcs-to-sparse), how does the verifier check $\tilde{Z}(\r_y)$?

### Step 6: Opening $\tilde{Z}(\boldsymbol{r}_y)$

Recall from [Step 1 above](#step-1-mles-of-r1cs-matrices-public-statement-and-private-witness) that:
 - $\tilde{Z}$ is the size $2^s$ MLE of $z = (\stmt, 1, \witn)\in\F^m$ and
 - $\tilde{P}$ is the size $2^{s-1}$ MLE of **only** the public statement $(\stmt, 1)\in \F^{m/2}$ 
 - $\tilde{W}$ is the size $2^{s-1}$ MLE of **only** the private witness $\witn\in \F^{m/2}$
    + and the verifier has an oracle $\oracle{\tilde{W}}$ to it

The verifier wants to compute $Z(\r_y)$ which, as per Eq. \ref{eq:Z}, can be expressed as:
\begin{align}
\label{eq:zry}
\tilde{Z}(\r_y) &= \underbrace{r\_{y,0} \cdot P(r\_{y,1}, \ldots, r\_{y,s-1})}\_{\text{reconstructable from}\ \stmt\ \text{and}\ \r_y} + (1-r\_{y,0})\cdot \underbrace{\tilde{W}(r\_{y,1},\ldots,r\_{y,s-1})}_{\text{give PCS opening proof}}
\end{align}

Therefore, it suffices to give the verifier an opening proof w.r.t. $c_\witn$:
\begin{align}
(\term{e_w}, \term{\pi_w}) \gets \dense.\open^\FSo(\tilde{W}, (r\_{y,t})_{t\in[1,s)})
\end{align}

So, given $\r_y$, $\stmt$, $c_\witn$, $e_w$ and $\pi_w$, the verifier will have everything it needs to verify $\tilde{Z}(\r_y)$ as per Eq. \ref{eq:zry}!
 

### Step 7: From sparse MLE PCS to dense

As explained in [Step 5](#step-5-from-three-sumchecks-to-four-mle-openings), the **main challenge** is we need an efficient PCS for sparse MLEs.

This is crucial for opening the R1CS MLEs at a random point in the second sumcheck from Eq. \ref{eq:second-sumcheck}.

A naive MLE PCS would be **extremely-inefficient**:
 - the R1CS matrices are of size $m\times m\Rightarrow$ they can be represented as a size-$m^2$ vector $V$. 
 - they are sparse, so only $n \approx m$ entries in $V$ are non-zero.
 - even though committing to the sparse MLE $\tilde{V}$ could be done in $O(n)$, not $O(m^2)$ via a **dense MLE PCS** scheme (e.g., PST[^PST13e]), two problems remain:
    1. The size of the structured reference string (SRS) could be $\Theta(m^2)$, which is too large
    2. The opening time for $\tilde{V}(\r_x,\r_y)$ in all previously-known dense MLE PCS schemes is $\Theta(m^2)$! (Would love to be shown wrong on this.)

To address this problem, Spartan proposes a compiler, called **Spark**.

Spark can take any dense MLE PCS for size-$n$ MLEs and turn it into a **sparse** one for size $m^2$ MLEs with only $n \approx m$ non-zero entries.

### Step 7.1: Spark: a dense-to-sparse MLE PCS compiler

Recall that $m=2^s$ and that we have a size-$m^2$ MLE $\tilde{V}$ of a sparse R1CS matrix, say, $V=(V\_{i,j})\_{i,j\in[m)}$ with $n\approx m$ non-zero entries:
\begin{align}
\tilde{V}(\X,\Y) = \sum\_{\i\in\binS,\j\in\binS} V\_{i,j}\cdot\eq\_i(\X)\eq\_j(\Y)
\end{align}

Our goal is to come up with an MLE PCS so we can efficiently and provably open $\tilde{V}$ at the random $(\r_x,\r_y)$ point picked by the verifier:
\begin{align}
\label{eq:r1cs-matrix-sumcheck}
\tilde{V}(\r_x,\r_y) = \sum_{\i\in\binS,\j\in\binS} A_{i,j}\cdot\eq_i(\r_x)\eq_j(\r_y)
\end{align}

For each R1CS matrix $V$, the universal setup will commit to three **dense** MLEs representing the non-zero entries $V_{i,j}$ in the matrix and their locations $i,j$.

Denote the set of non-zero entries in a matrix $V$ by:
\begin{align}
%N\_V \bydef 
\left(i_k,j_k,V_{i_k,j_k}\right)\_{k\in[n)}
\end{align}

Then, we can define three MLEs $\row,\col,\val : \F^{\log{n}} \rightarrow \F$ that represent this set as:
\begin{align}
\label{eq:rows-cols-vals}
\forall k\in[n),
\begin{cases}
    \term{\row(\k)} &= i_k \wedge {}\\\\\
    \term{\col(\k)} &= j_k \wedge {}\\\\\
    \term{\val(\k)} &= A_{i_k,j_k}
\end{cases}
%\row(\X) \bydef \sum_{\b\in\binS} 
\end{align}
(These can be interpolated [as usual](#multilinear-extensions-mles).)

Now assume a function that converts a row or column index $i\in[m)$ (or $j\in[m)$) to its $s$-bit binary representation:

$$\term{\bits} : [m) \rightarrow \binS$$

As a result, we can rewrite the R1CS matrix sumcheck from Eq. \ref{eq:r1cs-matrix-sumcheck} as:
\begin{align}
\label{eq:r1cs-sparse-sumcheck}
\tilde{V}(\r_x,\r_y) 
&= \sum_{\i\in\binS,\j\in\binS} V_{i,j}\cdot\eq_i(\r_x)\cdot\eq_j(\r_y)\\\\\
&= \sum_{\i\in\binS,\j\in\binS} V_{i,j}\cdot\eq_{\r_x}(\i)\cdot\eq_{\r_y}(\j)\\\\\
&= \sum_{V_{i,j}\ne 0} V_{i,j}\cdot\eq_{\r_x}(\i)\cdot\eq_{\r_y}(\j)\\\\\
\label{eq:r1cs-dense-sumcheck}
&= \sum_{k\in[n)} \val(\k)\cdot\eq_{\r_x}(\bits(\row(\k)))\cdot\eq_{\r_y}(\bits(\col(\k)))\\\\\
%&\bydef \sum_{k\in[n)} \val(\k)\cdot\eqr{V}(\k,\r_x)\eqc{V}(\k,\r_y)\\\\\
\end{align}

{: .error}
Unfortunately, the term inside the sum above from Eq. \ref{eq:r1cs-dense-sumcheck} is **not** a polynomial.
This is because $\bits$'s domain is $[m)$ and we cannot evaluate it on arbitrary field elements in $\F$.

My understanding so far is that Spark is an efficient protocol for "linearizing" the $\eq_{\r_x}(\bits(\row(\r_k)))$ expression into an MLE that agrees with it over hypercube (and its $\col$ counterpart).

{: .todo}
Describe the Spark approach, later refined by Lasso[^STW23e] and Shout[^ST25e].

## Spartan PIOP framework for (non-ZK) SNARKs

<!-- Here you can define LaTeX macros -->
<div style="display: none;">$
%\def\derive{\mathsf{Derive}}
\def\spartanProof{\begin{pmatrix}
    c_\witn, \pi_w, e_w,\\
    \pi_x, e_x, \pi_y, e_y,\\
    v_A, v_B, v_C,\\
    a_{x,y}, b_{x,y}, c_{x,y},\pi_{x,y}\\ \end{pmatrix}}
$</div>

We describe Spartan as a **framework** for obtaining (non-ZK) SNARKs given a dense MLE PCS $\dense$ and a sparse MLE PCS $\sparse$ (from a compiler like Spark[^Sett19e]).

Recall the main notation from before:
\begin{align}
Z &\bydef (\stmt, 1, \witn)\in \F^m\\\\\
P &\bydef (\stmt, 1)\\\\\
W &\bydef \witn\\\\\
F(\X) &\bydef \sum_{\j\in\binS} \tilde{A}(\X,\j) \tilde{Z}(\j) \cdot \sum_{\j\in\binS} \tilde{B}(\X,\j) \tilde{Z}(\j) - \sum_{\j\in\binS} \tilde{C}(\X,\j) \tilde{Z}(\j)\\\\\
\label{eq:mrx}
M_{\r_x}(\Y) &\bydef r_A \tilde{A}(\r\_x,\Y) \tilde{Z}(\Y) + r_B \tilde{B}(\r\_x,\Y) \tilde{Z}(\Y) + r_C \tilde{C}(\r\_x,\Y) \tilde{Z}(\Y)\\\\\
\end{align}

 - We often use $\tilde{V}$ to refer the MLE of a vector or matrix $V$.
    + (Recall that the R1CS matrices are denoted by $A,B,C$.)
 - We use $a\fsget S$ to denote sampling from a set $S$ in a deterministic manner using the Fiat-Shamir transcript derived so far

### $\mathsf{Spartan}_{\mathcal{D},\mathcal{S}}.\mathsf{Setup}(A, B, C) \Rightarrow (\prk,\vk)$

 - Let $m$ denote the number of rows and columns in the square matrices $A,B,C$
 - Let $n_A,n_B,n_C$ denote the max number of non-zero entries in $A,B$ and $C$, respectively
 - $n\gets \max{(n_A,n_B,n_C)}$
 - $(\prk_\dense,\vk_\dense)\gets \dense.\setup(s-1)$
 - $(\prk_\sparse,\vk_\sparse)\gets \sparse.\setup(s, n)$
 - $(c_A,c_B,c_C) \gets \sparse.\commit(\prk_\sparse, \tilde{A}, \tilde{B}, \tilde{C})$
 - $\vk\gets (c_A,c_B,c_C,\vk_\dense,\vk_\sparse)$
 - $\prk\gets (A,B,C,\vk, \prk_\dense,\prk_\sparse)$

### $\mathsf{Spartan}_{\mathcal{D},\mathcal{S}}.\mathsf{Prove}^{\mathcal{FS}(\cdot)}(\mathsf{prk}, \mathbf{x}; \mathbf{w}) \Rightarrow \pi$ 

Commit to the witness and set up the Fiat-Shamir transcript:
 - $(\cdot,\cdot,\cdot,\vk,\prk_\dense,\cdot)\parse \prk$
 - $c_\witn\gets\dense.\commit(\prk_\dense,\tilde{W})$
 - add $(\vk,c_\witn)$ to $\FS$ transcript

Prove the first sumcheck:
 - $\btau \fsget \F^s$
 - $(\pi_x, e_x; \r_x\in\F^s) \gets \SC.\prove(F\cdot \eq_\btau, 0, s, 3)$ (see Eq. \ref{eq:F})

Prove the second sumcheck:
 - $v_A \gets \sum_{\j\in\binS} \tilde{A}(\r_x,\j) \tilde{Z}(\j)$
 - $v_B \gets \sum_{\j\in\binS} \tilde{B}(\r_x,\j) \tilde{Z}(\j)$
 - $v_C \gets \sum_{\j\in\binS} \tilde{C}(\r_x,\j) \tilde{Z}(\j)$
 - $(r_A, r_B, r_C) \fsget \F^3$
 - $T\gets r_A v_A + r_B v_B + r_C V_C$ 
 - $(\pi_y, e_y; \r_y) \gets \SC.\prove(M_{\r_x}, T, s, 2)$ (see Eq. \ref{eq:mrx} and \ref{eq:second-sumcheck})

<!-- The Spartan proof, defined as a macro, to avoid mistakes -->
<div style="display: none;">$
\def\spartanProof{\begin{pmatrix}
    c_\witn, \pi_w, e_w,\\
    \pi_x, e_x, \pi_y, e_y,\\
    v_A, v_B, v_C,\\
    a_{x,y}, b_{x,y}, c_{x,y},\pi_{x,y}\\ \end{pmatrix}}
$</div>

Compute the necessary openings:
 - $(e_w, \pi_w) \gets\dense.\open^\FSo(\prk_\dense, \tilde{W},(r_{y,t})_{t\in[1,s)})$
 - $(a_{x,y},b_{x,y},c_{x,y};\pi_{x,y})\gets \sparse.\open^\FSo\begin{pmatrix}
    \prk_\sparse,
    (\tilde{A}, \tilde{B}, \tilde{C}),%\\\\\
    (\r_x,\r_y)
    \end{pmatrix}$
 - $\pi\gets\spartanProof$

#### Prover time

 - Witness-dependent:
    - dense MLE commitment to witness vector $W\bydef \witn$ (would need ZK)
    + degree-3 sumcheck for $F\cdot \eq_\btau$ (would need ZK)
    + degree-2 sumcheck for $M_{\r_x}$ (would need ZK)
    - dense MLE opening for $\tilde{W}$ (would need ZK)
 - Witness-independent:
    - sparse MLE openings for the R1CS matrices

{: .todo}
The two MLE openings should be batchable into one, even if at different points, via a sumcheck apparently[^GLHplus24e].
(This will drive up the proof size though.)

### $\mathsf{Spartan}_{\mathcal{D},\mathcal{S}}.\mathsf{Verify}^{\mathcal{FS}(\cdot)}(\mathbb{x}; \mathbf{\pi}) \Rightarrow \\{0,1\\}$

Parse the proof and set up the Fiat-Shamir transcript:
 - $\spartanProof\parse\pi$
 - add $(\vk,c_\witn)$ to $\FS$ transcript
 - $\r\fsget \F^s$

Verify the first sumcheck:
 - $\btau \fsget \F^s$
 - $(s_x; \r_x) \gets \SC.\verify^\FSo(0, e_x, 3; \pi_x)$
 - **assert** $s_x \equals 1$
 - **assert** $e_x \equals (v_A \cdot v_B - v_C)\cdot \eq_\btau(\r_x)$

Verify the second sumcheck:
 - $(r_A, r_B, r_C) \fsget \F^3$
 - $T\gets r_A v_A + r_B v_B + r_C V_C$
 - $(s_y; \r_y) \gets \SC.\verify^\FSo(T, e_y, 2; \pi_y)$
 - **assert** $s_y \equals 1$
 - $z_y \gets \left(r_{y,0} \tilde{P}(r_{y,1},\ldots,r_{y,s-1}) + (1-r_{y,0})e_w\right)$ 
 - **assert** $e_y \equals (r_A \cdot a_{x,y} + r_B \cdot b_{x,y} + r_C \cdot c_{x,y}) \cdot z_y$
 
Verify the $e_w \equals \tilde{W}(\r_y)$ opening:
 - $(\cdot,\cdot,\cdot,\vk_\dense,\cdot) \gets \vk$
 - **assert** $\dense.\verify^\FSo(\vk_\dense, c_\witn, (r_{y,t})_{t\in[1,s)}, e_w; \pi_w)$

Verify the R1CS MLE evaluations:
 - $(c_A, c_B, c_C,\cdot,\vk_\sparse) \gets \vk$
 - **assert** $\sparse.\verify^\FSo\begin{pmatrix}
    \vk_\sparse,
    (c_A, c_B, c_C),
    (\r_x, \r_y),
    (a_{x,y}, b_{x,y}, c_{x,y});
    \pi_{x,y}
\end{pmatrix}$

Succeed:
 - **return 1**

#### Verifier time

 - verify degree-3 sumcheck
 - verify degree-2 sumcheck
 - verify dense PCS opening
 - verify sparse PCS opening

## Conclusion

{: .todo}
Cost of making it ZK?
First, I think the dense MLE PCS for $\witn$ has to have hiding commitments with ZK openings.
Second, the univariate polynomials in Spartan's first and second sumchecks have to be blinded.
And that's it? Because the third sumcheck inside the sparse MLE PCS is on a public polynomial!

### Acknowledgements

Thanks to Weijie Wang for explaining Spark[^Sett19e].
Thanks to Albert Garreta for explaining through Spartan, Spark and other multivariate protocols.
Thanks to Justin Thaler, Kabir Peshawaria and Guru Vamsi Policharla for explaining many things about sumchecks, Spartan, and MLE PCSs.

## Appendix

### Spartan protocol from the original paper

<div align="center"><img style="width:75%" src="/pictures/spartan.png" /></div>

### Extra resources

 - [Sumcheck implementations, Kabir Peshawaria](https://gitlab.com/IrreducibleOSS/binius/-/tree/ad2d620e56dff3b18d502c6dafa557d6988ad920/crates/core/src/protocols)
    + [Simpler Python code here](https://github.com/IrreducibleOSS/binius-models/blob/main/binius_models/ips/sumcheck.py)

## References

For cited works, see below 👇👇

{% include refs.md %}
