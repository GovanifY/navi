navi's documentation
--

Before we begin, I'd like to state that navi is INCOMPLETE and has a bunch of
half-assed/unfinished features.
While I think the general code architecture and design of the project are fairly
commendable, them being unfinished makes them anti-features, driving users into
a sense of security. Please, before sharing parts of my configuration, do keep
that in mind and run your own audits, I haven't audited myself the configuration
yet!

navi also, in a perfect world, has a few features that are currently disabled:
always-on Tor proxying, Tor based infrastructure DNS lookup, malloc hardening,
"hidden" backups, heck even sandboxing which is currently a joke.
All of those features have, as of now, important enough quirks that I don't
feel confident leaving them enabled by default but they are still planned,
I just need to take some time to polish everything up!

As a last note, currently mobile devices are not planned to be supported in
navi. This is because of the Verified boot with remote signing approach that is
taken to enforce security on devices by any recent Android phones.
While I have my own qualms with this approach[1], I think this is an ill fit for
navi, where lateral movement between device groups (servers->headfull) is
designed to be impossible.

With that said I can still recommend GrapheneOS for that usage, with Tor as an
always-on VPN, disabling all connections before startup and possibly an
https://attestation.app setup in one of navi's server. If, as assumed in navi,
your attacker is a state-level threat, you might want to either leave the device
in WiFi only by enabling airplane mode or get a SIM card that is unrelated to
your current identity.

Thanks for reading all of those warnings! I'd just like to state that most of
this documentation was written at the start of navi and was barely updated after
and might not reflect the current state of things, code is authoritative, doc
isn't! Feel free to jump to code_architecture.txt for more information about
this codebase and don't get too mad at me :-)



--
[1]: The software provider can be backdoored and be forced to send out their
keys, unwillingly. While solutions like grapheneos tries to mitigate this by
only having minimal infos on your device (model, version, ip) updates can still
be targetted nevertheless by geoip-based targetting and/or VPN recognition, if
the user is using one. As a side-note this is a _hard_ problem and I have no
solutions to it, only mitigations. navi is also vulnerable to it at multiple
levels: git cloning heuristics, nixos cache backdooring, etc.
