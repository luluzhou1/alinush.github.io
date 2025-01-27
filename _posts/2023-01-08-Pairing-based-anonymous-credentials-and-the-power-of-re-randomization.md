---
tags:
 - digital signatures
 - bilinear maps (pairings)
title: Pairing-based anonymous credentials and the power of re-randomization
#sidebar:
#    nav: cryptomat
---

{: .info}
**tl;dr:** Pointcheval-Sanders (PS) signatures[^PS16] are incredibly powerful: (1) they can sign Pedersen commitments directly and (2) they can be re-randomized together with the signed commitment. This enables very simple schemes for proving yourself anonymously. For example, an authority can give you a PS signature on a commitment of your age and date-of-birth. If you wanna prove to a bar that you are 18 years or older, you can present the bar with a re-randomized signature on the re-randomized commitment together with a zero-knowledge proof that the difference between the current year and your committed birth year is greater than 18.

For more details, see this post on [Decentralized Thoughts](https://decentralizedthoughts.github.io/2023-01-08-re-rand-cred/)

<!--more-->

<p hidden>$$
\def\Adv{\mathcal{A}}
\def\Badv{\mathcal{B}}
\def\vect#1{\mathbf{#1}}
$$</p>

---

{% include refs.md %}
