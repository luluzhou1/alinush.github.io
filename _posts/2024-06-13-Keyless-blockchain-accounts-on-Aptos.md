---
tags:
title: Keyless blockchain accounts on Aptos
#date: 2020-11-05 20:45:59
#published: false
#sidebar:
#    nav: cryptomat
---

{: .info}
**tl;dr:** What is a **keyless blockchain account**?
Put simply, _"Your blockchain account = Your Google account"_. 
In other words, this keyless approach allows you to derive a blockchain account from any of your existing OpenID Connect (OIDC) account (e.g., Google, Apple), rather than from a traditional secret key or mnemonic. 
There are no long-term secret keys you need to manage.
There is also no multi-party computation (MPC) system managing your account for you.
As a result, the risk of account loss is (more or less), the risk of losing your Google account.

One day, I hope to edit this into a full blog post but, until then:
1. I wrote a **high-level** explanation of how keyless accounts work on the [Aptos](https://twitter.com/aptos) blockchain [here](https://aptos.dev/aptos-keyless/how-keyless-works).
2. I wrote an **in-depth** document explaining how keyless accounts work and their many caveats in [the 61th Aptos Improvement Proposal](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-61.md).
3. I did a few more things below 👇

## Other resources

A 20-minute presentation at zkSummit11 can be found below:
<iframe width="560" height="315" src="https://www.youtube.com/embed/sKqeGR4BoI0?si=GJDBwVoTHdS-pML6" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

An accompanying tweetstorm can be found below:
<blockquote class="twitter-tweet"><p lang="en" dir="ltr">What is an <a href="https://twitter.com/Aptos?ref_src=twsrc%5Etfw">@aptos</a> keyless account? 🧵<br><br>It&#39;s a blockchain account derived from (say) your Google account and an application (wallet, dapp, etc).<br><br>It&#39;s bound not just to you (e.g., you@gmail.com) but also to the application (e.g., <a href="https://twitter.com/PetraWallet?ref_src=twsrc%5Etfw">@PetraWallet</a>, or <a href="https://twitter.com/ThalaLabs?ref_src=twsrc%5Etfw">@ThalaLabs</a>, or <a href="https://twitter.com/VibrantXFinance?ref_src=twsrc%5Etfw">@VibrantXFinance</a>) <a href="https://t.co/L3qgRf1WoS">pic.twitter.com/L3qgRf1WoS</a></p>&mdash; Alin Tomescu (@alinush407) <a href="https://twitter.com/alinush407/status/1800949436371304955?ref_src=twsrc%5Etfw">June 12, 2024</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

<!--more-->

<p hidden>$$
\def\Adv{\mathcal{A}}
\def\Badv{\mathcal{B}}
\def\vect#1{\mathbf{#1}}
$$</p>

---

{% include refs.md %}
