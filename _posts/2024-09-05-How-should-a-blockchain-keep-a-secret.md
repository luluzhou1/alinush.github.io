---
tags: secret-sharing
title: How should a blockchain keep a secret?
#date: 2020-11-05 20:45:59
#published: false
#sidebar:
#    nav: cryptomat
article_header:
  type: cover
  image:
    src: /pictures/2024-09-05-dagstuhl-ngsdc.jpg
---

{: .info}
**tl;dr:** I was at the _Next-Generation Secure Distributed Computing_ seminar at Schloss Dagstuhl and spoke about how a blockchain should keep a secret.

<!--more-->

<!-- Here you can define LaTeX macros -->
<div style="display: none;">$
$</div>
<!-- $ 
-->

**Slides:** [here](https://docs.google.com/presentation/d/1lRR3scw_w-MhgiTGNgF--VeSxkQUdXmjgVGEG-dPTWY/edit?usp=sharing).

**Abstract:** In this talk, we survey results & challenges around **generating**, **maintaining** and **using** a shared secret amongst the validators of a proof-of-stake (PoS) blockchain.

In the first part, we discuss techniques for generating a secret.
We start with secret sharing in the threshold setting and then in the weighted setting that arises in PoS blockchains.
We then introduce publicly-verifiable secret sharing (PVSS), explaining why it could be an ideal primitive to build distributed key generation (DKG) protocols from.
Lastly, we discuss the new "silent setup" setting[^BGJplus23]$^,$[^DCXplus23e]$^,$[^GJMplus23e]$^,$[^GKPW24e] for bootstrapping threshold cryptosystems without a DKG or any explicit secret sharing (previously known as _"ad hoc groups"_ in the literature).

In the second part, we discuss the threat of collusion attacks in the PoS attacks, where validators stand to profit by exposing the shared secret or a function of it (e.g., the plaintext obtained after threshold decryption under the shared secret).
We present three different collusion attacks which are all detectable-but-unpunishable. 
We then give a TEE-based approach that could prevent collusion and call for more research in this direction.

In the third part, we discuss some new techniques used to speed up threshold cryptosystems.
We begin by reminding practitioners that Lagrange interpolation in threshold cryptosystems can **and should** be done via an optimized quasilinear time algorithm, instead of quadratic[^TCZplus20].
Then, we present new results on threshold cryptosystems that use group elements as secret key[^BO22e]$^,$[^DPTX24e]$^,$[^GJMplus21].
Lastly, we present an exciting new direction on batching threshold cryptosystems so that communication during aggregation is independent of the batch size.

Overall, we highlight important research problems in both the theory and the practice of threshold cryptography.

## Follow-up reading

Matthieu Rambaud suggested:
 - [Partially Non-Interactive Two-Round Lattice-Based Threshold Signatures
](https://eprint.iacr.org/2024/467)
 - The derived $\\{0,1\\}$-LSSS in [Threshold Fully Homomorphic Encryption](https://eprint.iacr.org/2017/257)
 - A tradeoff with $n^2$-sized shares: [Improved Universal Thresholdizer from Iterative Shamir Secret Sharing](https://eprint.iacr.org/2023/545)


---

{% include refs.md %}
