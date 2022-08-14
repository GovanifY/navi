navi
=====
navi(NixOS Advanced Virtual Infrastructure) is a set of NixOS configuration
files handling my own internal infrastructure.

Currently the machines populated by this configuration are:

* alastor
* xanadu

WARNING: This is a very heavily WIP project and has an uncommon threat model, as
such you might want to really document yourself before using parts of this
software! Please read `docs/README.txt` at the very least!


## Development Notes

To setup navi you'll first need to bootstrap it:

```
cd bootstrap && ./bootstrap.sh
```
This will setup secrets needed for the entire infrastructure to work.


If you want to test the setup before installing it on a real machine you can 

```
sudo nixos-rebuild build-vm -I nixos-config=./configuration.sample.nix
```

If you want to install navi on a live machine, you'll need to run the
bootstrapper again to generate device-specific keys, paths, and other required
components. It will generate a default configuration which you should tailor to
your needs. Installing is then as simple as running

```
sudo nixos-install
```

Don't forget to change your initial hashed password at boot for headfull, they
are written to the world readable nix store! Someone could try to LPE by
brute-forcing them.

## Contributing

Do not forget to run `pre-commit install` to get the formatting hooks running
before contributing!
