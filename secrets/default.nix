let
  canary_common =
    if (builtins.hashFile "sha256" ./common/assets/canary) != "4d16330208714286d397e2cf7d8a977ac2771ac9fa0311226afc0df06e00b4d6"
    then { }
    else ./common;
  canary_headfull =
    if (builtins.hashFile "sha256" ./headfull/assets/canary) != "b5482e455cc5311f33b6c9935f227fbd1537b7007f2f3c040caddde42a62ed90"
    then { }
    else ./headfull;
  canary_emet-selch =
    if (builtins.hashFile "sha256" ./emet-selch/assets/canary) != "9ff4df62ac21439e4d8573a0def554c8e130a1f6e45ba6925f94d5b62ec385ff"
    then { }
    else ./emet-selch;
in
{
  imports = [
    canary_common
    canary_headfull
    canary_emet-selch
  ];
}
