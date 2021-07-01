let
  canary =
    if (builtins.hashFile "sha256" ./secrets/common/assets/canary) != "4d16330208714286d397e2cf7d8a977ac2771ac9fa0311226afc0df06e00b4d6"
    then
      abort
        "Incorrect secrets. Please be sure to run ./bootstrap.sh if this
         is your first time using navi, otherwise run git-crypt unlock!"
    else { };
in
{
  imports = [
    ./components
    ./secrets
    ./profiles
    ./infrastructure
  ];

  config = canary;

}
