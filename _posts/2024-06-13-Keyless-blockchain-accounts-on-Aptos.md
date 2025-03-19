---
tags:
 - keyless
 - zero-knowledge proofs (ZKPs)
 - groth16
title: Keyless blockchain accounts on Aptos
#date: 2020-11-05 20:45:59
#published: false
#sidebar:
#    nav: cryptomat
permalink: keyless
---

{: .info}
**tl;dr:** What is a **keyless blockchain account**?
Put simply, _"Your blockchain account = Your Google account"_. 
In other words, this keyless approach allows you to derive a blockchain account from any of your existing OpenID Connect (OIDC) account (e.g., Google, Apple), rather than from a traditional secret key or mnemonic. 
There are no long-term secret keys you need to manage.
There is also no multi-party computation (MPC) system managing your account for you.
As a result, the risk of account loss is (more or less), the risk of losing your Google account.
Keyless is built using a [Groth16](/groth16) zero-knowledge proof to maintain privacy in both directions: prevent the blockchain from learning anything about your Google account & prevent Google from learning anything about your blockchain account and transaction activity.

One day, I hope to edit this into a full blog post but, until then, here's a bunch of resources.

## tl;dr

A quick 20 minute presentation on what this & how it works:

<iframe width="560" height="315" src="https://www.youtube.com/embed/sKqeGR4BoI0?si=GJDBwVoTHdS-pML6" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

## FAQ

### Who is this for?

So far, cryptocurrencies have been designed for power users who understand public-key cryptography.

In constrast, Keyless accounts are for any Web 2 user who has used the "Sign in with Google[^not-just-google]" flow before. (Basically, for everyone.)

Keyless accounts are primarily designed **for the bottom 90% of users**; _novice users_ who are not yet ready to manager their own 12-word seed phrase, mnemonic or secret key.

Such users often tend to:
 - lose their key, or
 - get phished for their key, or
 - accidentally-paste their key somewhere they shouldn't

But, keyless accounts were designed also **for first-time users**, who deserve and expect a smooth on-boarding experience when interacting with a dapp.

{: .warning}
**Newsflash:** Downloading a _new_ wallet for every _new_ chain and writing down a _new_ (extremely-sensitive) 12-word seed phrase is **not** smooth.
(It's not even sane.)
Reusing an existing 12-word seed phrase is not smooth either. Plus, would you want to? Do you trust this _new_ wallet on this _new_ chain?[^hardware-wallet]

### Can Google steal my keyless account?

_In principle_, keyless accounts can be set up so that, **if a malicious Google tries to steal your account, you have the power to stop it** by sending a cancellation TXN within a timeout period (e.g., 1 day)[^cancellation-txns].

*In practice* though, this **higher-security mode** of operation will not lead to the best user experience (e.g., across different devices[^esk-across-devices] or when a user's browser session is lost[^esk-not-in-local-storage]).
As a result, this is not the recommended mode on the [Aptos network](https://x.com/aptos), nor the most-widely supported one.

Instead, Aptos defaults to a **user-friendly mode** where users can access their account easily from different devices (even if the browser's history has been cleaned).
For this to work, Google must be allowed to sign TXNs on the user's behalf without a timeout period (see [flow](#flow-end-to-end-keyless-transacting)).
As a result, a malicious (or compromised) Google could abuse this power and steal a user's account. 

Is this okay?
Well, you have to [remember who keyless accounts are for](#who-is-this-for).

_First_, they are for **first-time users** who are not interested in (or know much about) 12-word mnemonics; they just want to easily sign up for your your dapp!
_Second_, they are for **novice users** who understand very little about the responsibility of custodying a 12-word seed phrase or mnemonic.

So, yes, this **is** okay, because the biggest threat for this user base is **key loss (or theft) caused by the user themselves.**
It's not Google.

Then, as a developer, if you want to (1) on-board users smoothly and (2) prevent them from shooting themselves in the foot, then **you should use keyless**[^optionality].

Put differently, Google can **protect** these users' keyless accounts much, **much** better than the users are able to secure a 12-word seed phrases.

{: .note}
Google's own bottom line depends on their ability to protect their OpenID Connect (OIDC) secret keys which secure your keyless account because **those same keys secure the widely-used "Sign in with Google" flow** all across the web!

<!--
#### But what if I am really important and Google steals my keyless account?

Yes, if you are important Google, or the NSA, or Lazarus, or God knows who will steal your account.

But you are likely not.

### Can Google lock me out of my keyless account? 

{: .todo}
Yes.
How likely is this to happen?
Is it more likely for you to lock yourself out if you manage your 12-word seed phrase. Yes!

{: .todo}
Also, it depends how determined Google is to do this. (e.g., maybe you still have your email)

{: .todo}
Use a cold backup key?
zkEmail reset.

### Can Google ban my keyless dapp?

{: .todo}
Yes.
How likely is this to happen?
Unclear, but you can prepare for it: add a 2nd factor (e.g., add Apple or an SK or a zkEmail).
Or, recovery service.

### Can Google passively monitor TXNs?

{: .todo}
Passively-malicious Google vs. actively-malicious.

#### My TXNs

#### All TXNs

### What if my Google is hacked?

{: .todo}
2FA.
"You've done well so far."

### What if I lose my pepper?

{: .todo}
Designed to preclude that problem: pepper service has got your back.

### But this is not decentralized, right?

{: todo}
The design **is** decentralized: prover service can be de-centralized, so can pepper-service.
The current deployment is not there yet, but will be.

### But this is not privacy preserving, right?

{: todo}
Same: design **is**, but prover & pepper services are not yet privacy-preserving.

### What if this takes off? Won't Google own us all?

### TODO
2 out of 3 across same email but different providers
2 out of 3 across same provider but your friends' emails
securing $1,000 dollars vs. $1,000,000 dollars -- kind of like adding mfa in Web2

-->

## Drawings

### Flow: Keyless on-chain verification

Depicts what the blockchain validators need to do to verify a keyless TXN submitted by a user, Alice.

<div align="center"><img style="width:85%" src="/pictures/keyless-on-chain-verification.png" /></div>

### ZK relation: Keyless authentication

The ZK relation needed for keyless:

<div align="center"><img style="width:65%" src="/pictures/keyless-zk-relation.png" /></div>

### Flow: End-to-end keyless transacting 

Depicts the full keyless flow: the user generating an ESK and EPK, the user signing into the dapp with the EPK as the OIDC `nonce`, the dapp getting a JWT, exchanging it for a pepper, getting a ZKP from the prover service, the user signing a TXN with their ESK, the dapp sending the TXN containing the ZKP and ephemeral signature, and finally the blockchain verifying everything.

<div align="center"><img style="width:95%" src="/pictures/keyless-overview.png" /></div>

### Flow: Paying an email address via [https://aptosconnect.app](https://aptosconnect.app)

<div align="center"><img style="width:95%" src="/pictures/keyless-pay-to-email.png" /></div>

### Flow: End-to-end keyless ZKless-transacting (currently, disabled)

In case of emergency (e.g., a serious soundness issue in the ZK circuit), keyless supports a **ZKless** mode that is **not** privacy preserving.
This, of course, is currently **disabled** on Aptos mainnet.

We depicts this (simpler) ZKless flow: the user generating an ESK and EPK, the user signing into the dapp with the EPK as the OIDC `nonce`, the dapp getting a JWT, the user signing a TXN with their ESK, the dapp sending the TXN containing the ephemeral signature, and finally the blockchain verifying everything.

<div align="center"><img style="width:65%" src="/pictures/keyless-zkless-overview.png" /></div>

### ZK relation: Oblivious pepper service

The ZK relation needed to implement an [oblivious pepper service][oblivious-pepper]:

<div align="center"><img style="width:65%" src="/pictures/keyless-oblivious-pepper-relation.png" /></div>

### Flow: Fetching your pepper obliviously 

We depict the flow for a dapp to fetch its user's pepper _obliviously_ from the pepper service, without leaking the user's ID nor the application's ID to the service.

<div align="center"><img src="/pictures/keyless-oblivious-pepper-flow.png" /></div>

## Write-ups

1. I wrote a [high-level overview](https://aptos.dev/en/build/guides/aptos-keyless/how-keyless-works) of how keyless accounts work on the [Aptos](https://twitter.com/aptos) blockchain 
2. I wrote an [in-depth explanation](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-61.md) of how keyless accounts work (and their many caveats) in the 61st Aptos Improvement Proposal. 
3. _Osikhena Oshomah_ wrote a keyless tutorial for devs called [Aptos Keyless Auth](https://jamiescript.hashnode.dev/aptos-keyless-auth)

## Slides

 - [Keyless blockchain accounts from ZKPs](https://docs.google.com/presentation/d/1wMFBRe7WZpKRbcjuLaIzv4MlUtC9yf7tnvntnv4AiTQ/edit?usp=sharing), MIT and Northeastern University, February 2025
 - [Keyless blockchain accounts from ZKPs](https://docs.google.com/presentation/d/1LNX4RAx0d34WRl57OLCdBKgxXyDGht4ROJ15jRkDALg/edit?usp=sharing), NoirCon 1, February 2025
 - [Keyless blockchain accounts from ZKPs](https://docs.google.com/presentation/d/1XpkB0t-Ns4SuCosyin83ED4RLoSvFMGjH5746DCshow/), GKR bootcamp, January 2025
 - [How Keyless works](https://docs.google.com/presentation/d/1gew0fD0QFNqV9snmoYnhRtLsHBoMX0wykouVn1CJbXc), 2024-2025
 - [Aptos Keyless accounts](https://docs.google.com/presentation/d/1nmDYfTiFKgAmPvsodkyrniV4USNdGUIGuWYRYaAxKgI/edit?usp=sharing), zkSummit'11, April 2024

## Code

 - Keyless blockchain validator logic [here](https://github.com/aptos-labs/aptos-core/blob/2c96107ddf0e48b7b3a3e6c67ff6cce3844d1abc/aptos-move/aptos-vm/src/keyless_validation.rs#L158)
 - Keyless **governance** logic [here](https://github.com/aptos-labs/aptos-core/blob/2c96107ddf0e48b7b3a3e6c67ff6cce3844d1abc/aptos-move/framework/aptos-framework/sources/keyless_account.move#L3)
 - Keyless **prover service** [here](https://github.com/aptos-labs/keyless-zk-proofs/tree/main/prover)
    + Built on top of our own [`rust-rapidsnark`](https://github.com/aptos-labs/rust-rapidsnark)
    + Which, in turn, is built on top of our own _hardened_ [`rapidsnark`](https://github.com/aptos-labs/rapidsnark)
 - Keyless **ZK circuit** `circom` code [here](https://github.com/aptos-labs/keyless-zk-proofs/tree/main/circuit)
 - Keyless **pepper service** [here](https://github.com/aptos-labs/aptos-core/tree/main/keyless/pepper)
 - Keyless TypeScript **SDK** [here](https://github.com/aptos-labs/aptos-ts-sdk/tree/main/src/core/crypto)
 
## Educational (d)apps and code

 - **Example:** Sending a keyless TXN to the Aptos `mainnet` via the SDK [here](https://github.com/aptos-labs/aptos-ts-sdk/blob/2386c07361f9a80f994f8b3ea22991549958402a/examples/typescript/keyless_mainnet.ts#L27)
 - **Example:** Simple Keyless dapp on Aptos [here](https://github.com/aptos-labs/aptos-keyless-example/tree/main/examples/keyless-example) with guide [here](https://aptos.dev/en/build/guides/aptos-keyless/simple-example)
 - **Example:** Federated keyless dapp on Aptos [here](https://github.com/aptos-labs/aptos-keyless-example/tree/main/examples/federated-keyless-example)
 - **Example:** End-to-end dapp with Keyless [here](https://github.com/aptos-labs/aptogotchi-keyless) with guide [here](https://learn.aptoslabs.com/en/code-examples/keyless)

## Deployed applications

 1. [Aptos Connect](https://aptosconnect.app)
 1. [Merkle Trade](https://merkle.trade)

## Aptos Improvement Proposals (AIPs)

AIPs for auxiliary keyless services:

 - [AIP-75: Prover service](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-75.md)
 - [AIP-81: Pepper service](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-81.md)
 - [AIP-67: Native JWK consensus](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-67.md)

AIPs for recent extensions to keyless:

 - [AIP-96: Federated Keyless](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-96.md)
    + Adds decentralized support for "federated" OIDC providers like Auth0, which have tenant-specific `iss`'s and JWKs and could not be scalably integrated into our [JWK consensus](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-67.md) mechanism
 - [AIP-108: "Audless" Federated Keyless](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-108.md)
 - Draft [AIP: Oblivious pepper service][oblivious-pepper]

## Tweets

A tweetstorm summarizing Aptos Keyless can be found below:
<blockquote class="twitter-tweet"><p lang="en" dir="ltr">What is an <a href="https://twitter.com/Aptos?ref_src=twsrc%5Etfw">@aptos</a> keyless account? 🧵<br><br>It&#39;s a blockchain account derived from (say) your Google account and an application (wallet, dapp, etc).<br><br>It&#39;s bound not just to you (e.g., you@gmail.com) but also to the application (e.g., <a href="https://twitter.com/PetraWallet?ref_src=twsrc%5Etfw">@PetraWallet</a>, or <a href="https://twitter.com/ThalaLabs?ref_src=twsrc%5Etfw">@ThalaLabs</a>, or <a href="https://twitter.com/VibrantXFinance?ref_src=twsrc%5Etfw">@VibrantXFinance</a>) <a href="https://t.co/L3qgRf1WoS">pic.twitter.com/L3qgRf1WoS</a></p>&mdash; Alin Tomescu (@alinush407) <a href="https://twitter.com/alinush407/status/1800949436371304955?ref_src=twsrc%5Etfw">June 12, 2024</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>


## Presentations

### zkSummit'11 (2024)


In April 2024, I gave a **20-minute presentation** at zkSummit11.

[Go back up](#tldr-talk) to see it!

### GKR bootcamp (2025)

In January 2025, I gave a 1 hour bootcamp on keyless accounts: 
<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/Z83ct5BG05s?si=gJr5Tvoz6szcdk06" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

### NoirCon 1 (2025)

In February 2025, I gave a 25 minute workshop on keyless accounts at AZTEC's [NoirCoin 1](https://lu.ma/38g79n99?tk=Ek10r8):
<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/NX0EZBKpgrg?si=O8Ltq8hMtUzXfeRZ" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

## Technical reference

{% include keyless-defs.md %}

{: .note}
The notation below will not be explicitly defined; just exercise intuition! 
e.g., $\maxaudval$ is clearly the maximum number of bytes in $\audval$.

### Hashing the identity commitment (IDC) in the address

\begin{align}
\addridc \bydef \poseidon^\F_4\left(
    \begin{array}{l}
        \pepper[0..30],\\\\\
        \poseidon^\mathbb{S}\_{\maxaudval}(\audval),\\\\\
        \poseidon^\mathbb{S}\_{\maxuidval}(\uidval),\\\\\
        \poseidon^\mathbb{S}\_{\maxuidkey}(\uidkey)\\\\\
    \end{array}
\right)
\end{align}

{: .todo}
Define $\poseidon^\mathbb{S}_\ell(s)$.

## Future work

### Noir

 - [Groth16 experimental `gnark` backend](https://github.com/lambdaclass/noir_backend_using_gnark)
 - [Noir-to-R1CS experimental](https://github.com/worldfnd/ProveKit/tree/main/noir-r1cs)

### Miscellaneous

 - Code: [AnonAdhar](https://github.com/anon-aadhaar/anon-aadhaar/blob/main/packages/circuits/src/helpers/signature.circom), by PSE, does RSA2048-SHA2-256 signature verification in `circom` within ~900K R1CS constraints


<!--more-->

<p hidden>$$
\def\Adv{\mathcal{A}}
\def\Badv{\mathcal{B}}
\def\vect#1{\mathbf{#1}}
$$</p>

[oblivious-pepper]: https://github.com/aptos-foundation/AIPs/pull/544

---

[^cancellation-txns]: This mode can be implemented via account abstraction or via smart contract wallets and would be most effective if your wallet (or some other trusted 3rd party) monitors the chain for key-rotation activities. If so, your wallet would submit the cancellation TXN. (This TXN can be pre-signed too.)
[^esk-across-devices]: Why? AFAICT, this flow will require transmitting an ephemeral secret key (ESK) across different devices in order to quickly get access to the same keyless account on all your devices.
[^esk-not-in-local-storage]: In this case, since the ESK is typically stored in the browser's _local storage_, it will be long gone and the user would have rely on Google's digital signatures to install a new ESK. But this installation would be subject to the timeout period.
[^hardware-wallet]: ...and very few new users can be assumed to have a hardware wallet so as to side-step the 12-word seed phrase problem (assuming the hardware wallet even supports the new chain that the new user is trying to experiment with).
[^not-just-google]: I use "Google" as a canonical example of an OIDC provider. I stress that keyless accounts are **not** restricted with Google and are designed to work with any OIDC provider (e.g., Apple, GitHub, Facebook, etc.)
[^optionality]: Plus, you can anyway later give optionality to your users and allow them to rotate their account to self-custody. Or, to have a backup secret key. Or, to only rely on Google as a recovery method with a timeout, as per the "highly-secure mode" [here](#can-google-steal-my-account). It's just like in the Web 2 world, users can add a 2nd authentication factor to their accounts.

{% include refs.md %}
