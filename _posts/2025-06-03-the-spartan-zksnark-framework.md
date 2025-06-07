---
tags:
 - zero-knowledge proofs (ZKPs)
 - polynomials
 - interpolation
 - rank-1 constraint systems (R1CS)
title: The Spartan zkSNARK framework
#date: 2020-11-05 20:45:59
published: false 
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
\def\b{\boldsymbol{b}}
\def\btau{\boldsymbol{\tau}}
\def\binS{\bin^s}
\def\i{\boldsymbol{i}}
\def\inst{\mathbb{x}}
\def\j{\boldsymbol{j}}
\def\r{\boldsymbol{r}}
$</div> <!-- $ -->

## Introduction

Spartan[^Sett19e]$^,$[^Sett20] is a framework for building zkSNARK schemes using the well-known **sumcheck protocol**[^LFKN92]$^,$[^Thal20] and a **sparse multilinear polynomial commitment scheme**, a.k.a. a **sparse MLE PCS**.

By the end of this blog post, you should be able to fully understand the Spartan protocol:
<div align="center"><img style="width:75%" src="/pictures/spartan.png" /></div>

## Preliminaries

 - we typically denote the **boolean hypercube** of size $2^s$ as $\binS\bydef\\{0,1\\}^s$
 - multilinear extensions (MLEs)
 - MLE PCS
 - sumcheck protocol
 - sumcheck reduction algorithm $\SC(F, S; \r)\rightarrow (\pi,e)$ that reduces $\sum_{\b \in \binS} F(\b) = S$ to (1) verifying a sumcheck proof $\pi$ and (2) verifiying a polynomial evaluation proof that $F(\r) = e$ for some random $\r\in \F^s$ (picked after $F$ is fixed).

### $\mathsf{eq}(\mathbf{X};\mathbf{b})$ Lagrange polynomials

We want to define a polynomial $\eq$ that evaluates to 1 when $\X = \b$ and to 0 when $\X \in \binS \setminus\\{\b\\}$:
\begin{align}
\term{\eq(\X;\b)} &\bydef \begin{cases}
1,\ \text{if}\ \X = \b\\\\\
0,\ \text{if}\ \X \ne \b, \X \in \binS
\end{cases}\\\\\
&= \prod_{i\in[s]}\left(b_i X_i + (1 - b_i) (1 - X_i)\right)\\\\\
&\bydef \term{\eq(X_1,\ldots, X_s; b_1,\ldots,b_s)}\\\\\
&\bydef \term{\eq_\b(X_1,\ldots, X_s)}\\\\\
\end{align}

{: .note}
The number of variables $s$ is clear from context, typically, so we do not include it anywhere in the notation.

{: .note}
<details>
<summary>
<em>👇 Why does this work? 👇</em>
</summary>
Try and evaluate $\eq(X,\b)$ at $\X = \b$ by evaluating each product term $b_i X_i + (1-b_i)(1-X_i)$ at $X_i = b_i$!
<br /><br/>

It would yield $b_i^2 + (1-b_i)^2$, which is always equal to 1 for $b_i\in\{0,1\}$.
So all product terms are 1 when $\X=\b$.
<br /><br/>

Next, try to evaluate at $X=\b'$ when $\b'\ne\b$.
In this case, there will be an index $i\in [s]$ such that $b'_i \ne b_i \Rightarrow b_i' = (1-b_i)$.
So, evaluating the $i$th product term at $(1-b_i)$ yields $b_i(1-b_i) + (1-b_i)(1-(1-b_i)) = b_i(1-b_i)+(1-b_i)b_i=2b_i(1-b_i)$ which is always 0.
Therefore, the product is zero when $\X\ne \b$.
</details>
 
### Multivariate zerocheck

We want to check that:
\begin{align}
F(\X) = 0, \forall X\in \binS
\end{align}
There is a nice zerocheck-to-sumcheck reduction for this!
Let:
\begin{align}
\label{eq:zerocheck}
Q(\Y)\bydef \sum_{\x\in\binS} F(\x)\cdot\eq(\x;\Y)
\end{align}
It can be shown the zerocheck is equivalent to picking a random $\btau\in\F^s$ and checking:
\begin{align}
Q(\btau) = \sum_{\x\in\binS} \left(F(\x)\cdot \eq(\x; \btau)\right) = 0
\end{align}
Let's see why.

**Theorem** (informal):
Pick $\btau$ randomly. Then, $Q(\btau) = 0 \Leftrightarrow F(\x) = 0, \forall \x \in \binS$.
(Roughly. There is a probability with which this does **not** hold. See lemma 4.3 in [Sett19e][^Sett19e] for a formal claim.)

**Proof** ("$\Leftarrow$"):
This follows from the definition of $Q(\cdot)$ from Eq. \ref{eq:zerocheck}, by just swapping $F(\X)$ with 0 and observing $Q$ is zero everywhere, including at $\btau$.

**Proof** [by contradiction] ("$\Rightarrow$"):
Suppose that $Q(\btau) = 0$ at a random $\tau$ yet $\exists x\in\binS$ such that $F(\x) \ne 0$.
Then, again from the definition of $Q(\cdot)$ from Eq. \ref{eq:zerocheck}, this implies that $Q(\Y)$ is a non-zero polynomial.
(Because one of the terms of the sum will have a non-zero $F(\x)$ value.)
Roughly, this contradicts the Schwartz-Zippel lemma.

### R1CS matrices

[R1CS](/r1cs) matrices $\term{A}, \term{B}, \term{C}$ are assumed to be **square** (of $\term{m}$ rows and $m$ columns) and **sparse**, with $\term{n}$ non-zero entries.

Constraint system is **satisfiable** if exists $z\in \F^m$ such that:
\begin{align}
\label{eq:r1cs-sat}
A z \circ B z = C z
\end{align}
where:
\begin{align}
\label{eq:z}
\term{z} = (\term{io}, 1, \term{w}) \in \mathbb{F}^{|io|} \times \mathbb{F} \times \mathbb{F}^{m-|io|-1}
\end{align}
with $\term{io}$ being the **public statement** and $\term{w}$ being the **private witness**.

### R1CS instance

For convenience, an **R1CS instance** is defined as:
\begin{align}
\label{eq:r1cs-instance}
\term{\inst} = (\mathbb{F},A,B,C,io,m,n)
\end{align}

{: .note}
Note that an R1CS instance includes the public statement $io$, but not the private witness $w$.
It also includes the R1CS (square) matrix size $m$ and the # of non-zero entries $n$.

{: .definition}
An R1CS instance is said to be **satisfiable** iff. exists a private witness $w$ s.t. Eq. $\ref{eq:r1cs-sat}$ holds.
We also say the instance is **satisfied by** $w$.

## R1CS SAT $\Leftrightarrow$ zero sumcheck on degree-3 $\log{m}$-variate polynomial

We focus this blog post on explaining how Spartan obtains a SNARK (no ZK) by reducing R1CS satisfiability from Eq. \ref{eq:r1cs-sat} to two sumchecks and a batched polynomial evaluation.

{: .todo}
ZK!

Let $\term{s}=\lceil \log{m} \rceil$, where $\log$'s base is always 2.

### Step 1: From R1CS matrices, public statement and private witness to MLEs

We represent the R1CS matrices $A$, $B$ and $C$ as **multilinear extensions (MLE)**.
For example, for $A \bydef (A_{i,j})\_{i,j\in[m)}$, we define:
\begin{align}
\term{\tilde{A}(X_1, \ldots, X_s, Y_1,\ldots,Y_s)} \bydef \term{\tilde{A}(\X,\Y)} = \sum_{\i,\j \in \binS} A_{i,j} \cdot \eq(\X, \i)\eq(\Y,\j)
\end{align}
such that:
\begin{align}
\tilde{A}(\i,\j)=A_{i,j},\forall i,j\in[m)
\end{align}
where $i\in[m)$ is a row index, $j\in[m)$ is a column index and $\i,\j\in \binS$ are their $s$-bit binary representations, 

Similarly, the vector $z = (io, 1, w) \in \mathbb{F}^m$ can be viewed as an MLE:
\begin{align}
\term{Z} : \binS \rightarrow \mathbb{F},\ \text{s.t.}\ Z(\j) = z_j, \forall j\in[m)
\end{align}

{: .definition}
It may be useful to refer to the $\tilde{A},\tilde{B},\tilde{C}$ and $Z$ MLEs as **the R1CS instance MLEs**.
(Slightly abusing notation though, since $Z$ contains the witnness $w$ too, which the R1CS instance $\inst$ does not.)

### Step 2: R1CS satisfiability $\Leftrightarrow$ degree-2 zerocheck

Then, satisfiability of an R1CS instance $A,B,C$ with public input $io$ by witness $w$ can be expressed as:

\begin{align}
\forall\ \text{rows}\ i\in[m), \sum_{j\in[m)} A_{i,j} z_j \cdot \sum_{j\in[m)} B_{i,j} z_j - \sum_{j\in[m)} C_{i,j} z_j = 0\Leftrightarrow\\\\\
\forall\ \i\in\binS, \sum_{\j\in\binS} \tilde{A}(\i,\j) Z(\j) \cdot \sum_{\j\in\binS} \tilde{B}(\i,\j) Z(\j) - \sum_{\j\in\binS} \tilde{C}(\i,\j) Z(\j) = 0
%\Leftrightarrow\\\\\
%\forall \x\in \binS, \sum_{\j\in\binS} \tilde{A}(\x,\j) Z(\j) \cdot \sum_{\j\in\binS} \tilde{B}(\x,\j) Z(\j) - \sum_{\j\in\binS} \tilde{C}(\x,\j) Z(\j) = 0\Leftrightarrow\\\\\
\end{align}
More formally, define a degree-2 multivariate polynomial $\term{F}$ associated with the R1CS instance $\inst$:
\begin{align}
\label{eq:F}
\term{F(\X)}
&\bydef \sum_{\j\in\binS} \tilde{A}(\X,\j) Z(\j) \cdot \sum_{\j\in\binS} \tilde{B}(\X,\j) Z(\j) - \sum_{\j\in\binS} \tilde{C}(\X,\j) Z(\j)
\end{align}

Then, the main result of Spartan can be stated as a theorem:

{: .theorem}
An R1CS instance $\inst$ (see Eq. \ref{eq:r1cs-instance}) is satisfied by a witness $w \Leftrightarrow F(\x) = 0$ for all $\x \in \binS$ (i.e., $F$ is zero on the hypercube).

### Step 3: From zerocheck to degree-3 sumcheck

{: .todo}
Do I really need to introduce $G$ here?

Of course, [we know from before](#zero-check) that such a zerocheck on $F$ can be reduced to a sumcheck on another related polynomial $\term{G}$:
\begin{align}
\label{eq:G}
\term{G(\X)}\bydef F(\X)\cdot \eq_\term{\btau}(\X)
%G(\Y)\bydef \sum_{x\in\binS} F(\x)\cdot \eq(\x, \Y)
\end{align}
where $\term{\btau}\randget\F^s$ is randomly picked by the prover.
Specifically:
\begin{align}
\label{eq:sumcheck-1}
F(\x) &= 0,\forall x\in\binS \Leftrightarrow \sum_{\x\in\binS} F(\x)\cdot \eq_\btau(\x) = 0,\btau\randget\F^s
\end{align}
This sumcheck from Eq. \ref{eq:sumcheck-1} is reduced to (1) verifying a polynomial evaluation $\term{e_x}$ at a random point $\term{\r_x}\in \F^s$ 
\begin{align}
\term{e_x} \bydef G(\r_x)
%= F(\r_x)\cdot \eq(\term{\r_x},\btau)
\end{align}
...and (2) verifying a sumcheck proof $\term{\pi_x}$ by running the sumcheck protocol:
\begin{align}
\label{eq:first-sumcheck}
(\term{\pi_x} ,e_x) \gets \SC(G, 0; \r_x)
%= \SC(F\cdot \eq_\btau, 0; \r_x)
\end{align}
First, note that it is easy to verify the $\eq_\btau(\r_x)$ part of the evaluation.
Unfortunately, verifying that $F(\r_x)$ is correct is trickier, due to $F$'s complicated formula from Eq. \ref{eq:F}.

Fortunately, Spartan observes that this complicated formula itself is sumcheck-like!

{: .definition}
We refer to the sumcheck from Eq. \ref{eq:first-sumcheck} as Spartan's **first sumcheck**!

### Step 4: From $F(\boldsymbol{r}_x)$ to degree-2 sumchecks on the R1CS instance MLEs

i.e., to $\sum_\j \tilde{U}(\r_x, \j)$ (for each R1CS matrix $U$) sumchecks plus a $\sum_\j Z(\j)$ sumcheck will be needed to evaluate $F$ as per Eq. \ref{eq:F}.

Specifically, to prove $F(\r_x)$ set $\X = \r_x$ in its Eq. \ref{eq:F} formula:
\begin{align}
\label{eq:Frx}
F(\r_x)
&= \sum_{\j\in\binS} \tilde{A}(\r_x,\j) Z(\j) \cdot \sum_{\j\in\binS} \tilde{B}(\r_x,\j) Z(\j) - \sum_{\j\in\binS} \tilde{C}(\r_x,\j) Z(\j)\\\\\
\end{align}
If we denote the three sums above by:
\begin{align}
\label{eq:three-sumchecks}
\term{v_A} &\bydef \sum_{\j\in\binS} \tilde{A}(\r_x,\j) Z(\j)\\\\\
\term{v_B} &\bydef \sum_{\j\in\binS} \tilde{B}(\r_x,\j) Z(\j)\\\\\
\term{v_C} &\bydef \sum_{\j\in\binS} \tilde{C}(\r_x,\j) Z(\j)\\\\\
\end{align}
...we have:
\begin{align}
F(\r_x) = v_A \cdot v_B - v_C
\end{align}

### Step 5: From three sumchecks to four MLE openings

The three degree-2 sumchecks from Eq. \ref{eq:three-sumchecks} can be batched into a single one, also degree-2 (a small detail that I hope will not complicate the exposition too much).
First, pick random scalars:
\begin{align}
\term{(r_A, r_B, r_C)}\randget\F^3\\\\\
\end{align}
Second, reduce the three sumchecks above into one sumcheck (via a random linear combination):
\begin{align}
\label{eq:batched-sumcheck}
\term{t} &\bydef r\_A v\_A \cdot r\_B v\_B - r\_C v\_C \\\\\
&= r\_A\left(\sum\_{\j\in\binS} \tilde{A}(\r\_x,\j) Z(\j)\right) +
r\_B\left(\sum\_{\j\in\binS} \tilde{B}(\r\_x,\j) Z(\j)\right) + 
r\_C\left(\sum\_{\j\in\binS} \tilde{C}(\r\_x,\j) Z(\j)\right)\\\\\
&= \sum\_{\j\in\binS} \left(\underbrace{r_A \tilde{A}(\r\_x,\j) Z(\j) +
 r_B \tilde{B}(\r\_x,\j) Z(\j) + 
 r_C \tilde{C}(\r\_x,\j) Z(\j)}\_{\term{M\_{\r_x}(\j)}}\right)\\\\\
\end{align}
As a result, the prover only does a single sumcheck on the (implicit) $\term{M_{\r_x}(\Y)}$ polynomial from above (instead of three as per Eq. \ref{eq:three-sumchecks}):
\begin{align}
\label{eq:second-sumcheck}
(\pi_y, e_y) \gets \SC(M_{\r_x}, t; \r_y)
\end{align}

{: .definition}
We refer to the sumcheck from Eq. \ref{eq:second-sumcheck} as Spartan's **second sumcheck**!
(Recall the first one was in Eq. \ref{eq:first-sumcheck}).

Of course, this second sumcheck ultimately reduces to evaluating the $\tilde{A},\tilde{B},\tilde{C}$ R1CS MLEs and the $Z$ MLE (from [Step 1](#step-1-from-r1cs-matrices-public-statement-and-private-witness-to-mles)) at $\X = \r_x$ and $\Y=\r_y$.
As long as the verifier has commitments to the R1CS MLEs and to (the public part of) $Z$, it can verify this 2nd sumcheck (and everything else described so far)!

And **that** is the most difficult task in Spartan: it needs an efficient polynomial commitment scheme (PCS) for the MLEs representing the sparse R1CS matrices: a.k.a., a **sparse MLE PCS** to efficiently prove that:
\begin{align}
\label{eq:r1cs-evals}
v_1 \bydef \tilde{A}(\r_x,\r_y)\\\\\
v_2 \bydef \tilde{B}(\r_x,\r_y)\\\\\
v_3 \bydef \tilde{C}(\r_x,\r_y)\\\\\
\end{align}
After, the verifier can check that $e_y \equals M(\r_x,\r_y)$ as:
\begin{align}
e_y \equals (r_A v_1 + r_B v_2 + r_C v_3) \cdot Z(\r_y)
\end{align}

{: .todo}
Continue... explain the Z evaluations, maybe find better notation for $v_1, v_2, v_3$.

## Spark compiler

{: .todo}
Define algorithms for Spark that can be used below.

## Spartan PIOP framework

### $\mathsf{Spartan}.\mathsf{Prove}(\mathbb{x}; \mathbf{w}) \Rightarrow \pi$  

### $\mathsf{Spartan}.\mathsf{Verify}(\mathbb{x}; \mathbf{\pi}) \Rightarrow \\{0,1\\}$  



## References

For cited works, see below 👇👇

<!-- PWS
The R1CS matrices can be viewed as functions mapping a row and column index to their associated cell's value; i.e. "overload" the notation for matrix $A$ into a function:
\begin{align}
A : \binS\times\binS \rightarrow \mathbb{F}
%A : [m)\times[m) \rightarrow \mathbb{F},
\ \text{s.t.}\ A(\i,\j)\bydef A_{i,j}
\end{align}
where $i$ is a row index, $j$ is a column index and $\i,\j\in \binS$ are their $s$-bit binary representations.
-->

<!-- Univariate perspective
\begin{align}
\forall\ \text{rows}\ i\in[m), \sum_{j\in[m)} A_{i,j} z_j \cdot \sum_{j\in[m)} B_{i,j} z_j - \sum_{j\in[m)} C_{i,j} z_j = 0\Leftrightarrow\\\\\
\forall\ i\in[m), \sum_{j\in[m)} A(i,j) Z(j) \cdot \sum_{j\in[m)} B(i,j) Z(j) - \sum_{j\in[m)} C(i,j) Z(j) = 0\Leftrightarrow\\\\\
\forall\ i\in[m), \sum_{j\in[m)} \tilde{A}(i,j) Z(j) \cdot \sum_{j\in[m)} \tilde{B}(i,j) Z(j) - \sum_{j\in[m)} \tilde{C}(i,j) Z(j) = 0\Leftrightarrow\\\\\
\forall X\in [m), \sum_{j\in[m)} \tilde{A}(X,j) Z(j) \cdot \sum_{j\in[m)} \tilde{B}(X,j) Z(j) - \sum_{j\in[m)} \tilde{C}(X,j) Z(j) = 0\Leftrightarrow\\\\\
\end{align}
So, if we define:
\begin{align}
F(X)
&\bydef \sum_{j\in[m)}   \tilde{A}(X,j) Z(j) \cdot \sum_{j\in[m)}   \tilde{B}(X,j) Z(j) - \sum_{j\in[m)}   \tilde{C}(X,j) Z(j)\\\\\
     &= \sum_{j\in\binS} \tilde{A}(X,j) Z(j) \cdot \sum_{j\in\binS} \tilde{B}(X,j) Z(j) - \sum_{j\in\binS} \tilde{C}(X,j) Z(j)\\\\\
\end{align}

Then, the main result of Spartan can be stated as follows. 

**Theorem**: An R1CS instance $\inst$ is satisfied by $w$, iff. $F(X) = 0$ for all $X \in [m) = \\{0,1\\}^s$ (i.e., $F$ is zero on the hypercube).

-->

{% include refs.md %}
