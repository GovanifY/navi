{ config, lib, pkgs, ... }:
with lib;
{
  imports = [
    ./hardware.nix
  ];

  config = mkIf (config.navi.device == "emet-selch") {
    networking = {
      hostName = "emet-selch";
      domain = "govanify.com";
    };

    users.motd = ''
      [49m                                                                                    [0m
                                                                                          [0m
                                                                                          [0m
                                         [38;2;55;33;16m▄[38;2;90;52;34;48;2;55;33;16m▄[38;2;116;72;34m▄[38;2;154;90;34;48;2;116;72;34m▄[38;2;189;124;54m▄▄▄[38;2;116;72;34;48;2;62;66;73m▄▄[49m                                        [0m
                              [38;2;13;8;15;48;2;177;177;188m▄[38;2;133;136;156;48;2;231;214;224m▄      [38;2;231;214;224;49m▄[38;2;177;177;188m▄[48;2;55;33;16m [48;2;90;52;34m  [48;2;116;72;34m [38;2;154;90;34m▄▄[38;2;116;72;34;48;2;90;52;34m▄[38;2;90;52;34;48;2;154;90;34m▄[38;2;55;33;16;48;2;189;124;54m▄▄[48;2;116;72;34m▄[38;2;116;72;34;49m▄▄▄                                    [0m
                               [38;2;55;33;16;48;2;13;8;15m▄▄[38;2;13;8;15;48;2;133;136;156m▄[38;2;133;136;156;48;2;177;177;188m▄[48;2;231;214;224m▄▄[38;2;177;177;188m▄  [38;2;231;214;224;48;2;177;177;188m▄[38;2;177;177;188;48;2;90;52;34m▄ [38;2;90;52;34;48;2;116;72;34m▄[38;2;55;33;16m▄[48;2;90;52;34m▄[48;2;55;33;16m [38;2;154;90;34m▄[38;2;90;52;34m▄▄▄ [48;2;189;124;54m▄▄[38;2;189;124;54;48;2;116;72;34m▄▄[38;2;116;72;34;49m▄                                 [0m
                             [38;2;55;33;16m▄[48;2;55;33;16m  [38;2;177;177;188m▄▄[48;2;13;8;15m  [38;2;13;8;15;48;2;133;136;156m▄  [38;2;133;136;156;48;2;177;177;188m▄[48;2;231;214;224m  [38;2;231;214;224;48;2;177;177;188m▄[38;2;55;33;16;48;2;90;52;34m▄[38;2;90;52;34;48;2;55;33;16m▄[48;2;90;52;34m [48;2;116;72;34m [38;2;154;90;34m▄ [48;2;90;52;34m   [38;2;90;52;34;48;2;55;33;16m▄[38;2;116;72;34;48;2;90;52;34m▄▄ [38;2;90;52;34;48;2;189;124;54m▄[38;2;189;124;54;48;2;116;72;34m▄[38;2;116;72;34;49m▄                               [0m
                            [38;2;55;33;16m▄[38;2;177;177;188;48;2;55;33;16m▄[38;2;255;251;239;48;2;177;177;188m▄[48;2;231;214;224m▄▄   [38;2;231;214;224;48;2;177;177;188m▄▄[38;2;177;177;188;48;2;133;136;156m▄ [48;2;231;214;224m   [48;2;90;52;34m  [48;2;116;72;34m [48;2;154;90;34m  [38;2;154;90;34;48;2;116;72;34m▄[38;2;116;72;34;48;2;90;52;34m▄   [38;2;90;52;34;48;2;116;72;34m▄ [38;2;154;90;34m▄[48;2;90;52;34m  [38;2;90;52;34;48;2;189;124;54m▄[38;2;189;124;54;48;2;116;72;34m▄[38;2;116;72;34;49m▄                             [0m
                           [38;2;31;18;19m▄[38;2;177;177;188;48;2;55;33;16m▄[48;2;231;214;224m [48;2;255;251;239m  [38;2;231;214;224m▄[38;2;255;251;239;48;2;231;214;224m▄[48;2;255;251;239m [38;2;177;177;188m▄[38;2;71;71;81;48;2;231;214;224m▄▄[38;2;133;136;156m▄[38;2;177;177;188m▄  [38;2;133;136;156;48;2;177;177;188m▄[48;2;90;52;34m [38;2;90;52;34;48;2;116;72;34m▄[38;2;31;18;19;48;2;90;52;34m▄[48;2;31;18;19m   [48;2;90;52;34m▄[38;2;90;52;34;48;2;116;72;34m▄[48;2;90;52;34m   [48;2;116;72;34m▄▄▄[48;2;90;52;34m  [48;2;189;124;54m▄ [48;2;116;72;34m [49m                            [0m
                           [38;2;133;136;156;48;2;31;18;19m▄[48;2;177;177;188m [48;2;231;214;224m   [48;2;255;251;239m  [38;2;177;177;188;48;2;231;214;224m▄[48;2;71;71;81m     [38;2;71;71;81;48;2;133;136;156m▄[38;2;177;177;188;48;2;231;214;224m▄[48;2;90;52;34m [38;2;31;18;19m▄[48;2;31;18;19m      [48;2;55;33;16m [48;2;90;52;34m   [38;2;90;52;34;48;2;55;33;16m▄[38;2;55;33;16;48;2;90;52;34m▄    [38;2;90;52;34;48;2;189;124;54m▄ [48;2;116;72;34m [49m                           [0m
                          [48;2;31;18;19m [48;2;133;136;156m [38;2;133;136;156;48;2;177;177;188m▄[38;2;177;177;188;48;2;231;214;224m▄  [38;2;231;214;224;48;2;255;251;239m▄ [48;2;177;177;188m [48;2;71;71;81m  [38;2;192;98;89m▄ [48;2;71;71;81m▄ [48;2;133;136;156m [48;2;90;52;34m▄[38;2;236;123;94;48;2;31;18;19m▄▄[38;2;245;168;127m▄[48;2;192;98;89m▄[38;2;236;123;94m▄[38;2;192;98;89;48;2;31;18;19m▄ [48;2;55;33;16m [38;2;31;18;19m▄[48;2;90;52;34m▄▄[38;2;55;33;16m▄▄[48;2;55;33;16m [48;2;90;52;34m  [38;2;90;52;34;48;2;55;33;16m▄[38;2;55;33;16;48;2;90;52;34m▄[48;2;189;124;54m▄ [38;2;189;124;54;48;2;116;72;34m▄[38;2;116;72;34;49m▄                         [0m
                          [48;2;55;33;16m [48;2;133;136;156m   [38;2;133;136;156;48;2;177;177;188m▄[48;2;231;214;224m▄  [48;2;177;177;188m [38;2;236;123;94;48;2;71;71;81m▄[48;2;192;98;89m▄[48;2;236;123;94m  [38;2;245;168;127m▄[48;2;245;168;127m        [48;2;236;123;94m▄[48;2;31;18;19m [38;2;55;33;16;48;2;90;52;34m▄[38;2;90;52;34;48;2;55;33;16m▄▄▄▄[48;2;90;52;34m [48;2;116;72;34m  [48;2;90;52;34m   [48;2;55;33;16m [38;2;55;33;16;48;2;154;90;34m▄[48;2;189;124;54m [38;2;189;124;54;48;2;116;72;34m▄[38;2;116;72;34;49m▄                        [0m
                         [38;2;55;33;16;48;2;31;18;19m▄[48;2;55;33;16m [48;2;133;136;156m [38;2;177;177;188m▄   [48;2;177;177;188m [48;2;231;214;224m [48;2;133;136;156m [48;2;236;123;94m   [48;2;245;168;127m [48;2;177;177;188m [38;2;231;214;224m▄[48;2;245;168;127m        [38;2;245;168;127;48;2;236;123;94m▄[38;2;13;8;15;48;2;55;33;16m▄ [38;2;55;33;16;48;2;90;52;34m▄[38;2;90;52;34;48;2;116;72;34m▄ [38;2;154;90;34;48;2;90;52;34m▄▄[38;2;116;72;34m▄ [48;2;90;52;34m▄ [38;2;189;124;54m▄[38;2;31;18;19;48;2;55;33;16m▄ [38;2;154;90;34;48;2;189;124;54m▄ [48;2;116;72;34m [49m                       [0m
                        [38;2;31;18;19m▄[48;2;55;33;16m  [48;2;31;18;19m [48;2;177;177;188m  [48;2;133;136;156m  [38;2;231;214;224;48;2;177;177;188m▄[38;2;177;177;188;48;2;231;214;224m▄[38;2;13;8;15;48;2;133;136;156m▄[38;2;52;49;54;48;2;192;98;89m▄[48;2;236;123;94m [48;2;245;168;127m  [38;2;245;168;127;48;2;192;98;89m▄▄[48;2;245;168;127m    [38;2;236;123;94m▄[38;2;192;98;89m▄[38;2;13;8;15m▄▄▄[38;2;71;71;81;48;2;236;123;94m▄ [38;2;236;123;94;48;2;31;18;19m▄[48;2;55;33;16m▄[48;2;31;18;19m    [38;2;31;18;19;48;2;55;33;16m▄▄[48;2;90;52;34m▄[38;2;55;33;16m▄[48;2;189;124;54m [38;2;189;124;54;48;2;31;18;19m▄[38;2;31;18;19;48;2;55;33;16m▄[38;2;154;90;34;48;2;189;124;54m▄ [48;2;116;72;34m [49m                      [0m
                       [38;2;55;33;16;48;2;31;18;19m▄[48;2;55;33;16m  [48;2;31;18;19m  [38;2;133;136;156;48;2;177;177;188m▄▄[48;2;133;136;156m [38;2;177;177;188m▄[48;2;231;214;224m [38;2;133;136;156;48;2;177;177;188m▄[38;2;192;98;89;48;2;13;8;15m▄  [38;2;13;8;15;48;2;236;123;94m▄[38;2;52;49;54;48;2;245;168;127m▄   [38;2;236;123;94;48;2;13;8;15m▄      [38;2;13;8;15;48;2;236;123;94m▄[38;2;52;49;54m▄   [38;2;236;123;94;48;2;31;18;19m▄[38;2;245;168;127m▄[48;2;245;168;127m [38;2;192;98;89m▄▄[38;2;245;168;127;48;2;31;18;19m▄[38;2;55;33;16m▄▄[38;2;31;18;19;48;2;55;33;16m▄[48;2;189;124;54m [38;2;189;124;54;48;2;31;18;19m▄ [48;2;189;124;54m [48;2;116;72;34m [49m                      [0m
                       [38;2;31;18;19;48;2;55;33;16m▄ [48;2;31;18;19m  [38;2;133;136;156m▄[48;2;133;136;156m [38;2;177;177;188m▄[38;2;231;214;224;48;2;177;177;188m▄[38;2;177;177;188;48;2;231;214;224m▄[38;2;133;136;156;48;2;177;177;188m▄[48;2;13;8;15m    [38;2;13;8;15;48;2;52;49;54m▄[38;2;52;49;54;48;2;236;123;94m▄[48;2;245;168;127m    [38;2;245;168;127;48;2;236;123;94m▄[38;2;13;8;15;48;2;52;49;54m▄[38;2;133;136;156;48;2;13;8;15m▄[38;2;177;177;188m▄[38;2;246;163;63m▄▄[38;2;169;103;58m▄▄[38;2;246;163;63m▄[38;2;13;8;15;48;2;52;49;54m▄[38;2;52;49;54;48;2;236;123;94m▄[48;2;245;168;127m [38;2;192;98;89m▄[48;2;192;98;89m  [38;2;236;123;94m▄[48;2;245;168;127m [48;2;31;18;19m [38;2;31;18;19;48;2;55;33;16m▄ [38;2;55;33;16;48;2;90;52;34m▄[48;2;189;124;54m [48;2;31;18;19m [38;5;0;48;2;116;72;34m▄[49m                       [0m
                        [38;5;0;48;2;31;18;19m▄ [38;2;31;18;19;48;2;133;136;156m▄[38;2;133;136;156;48;2;231;214;224m▄[38;2;177;177;188m▄▄[38;2;133;136;156m▄[38;2;152;74;79;48;2;133;136;156m▄[48;2;52;49;54m [38;2;177;177;188;48;2;133;136;156m▄[48;2;177;177;188m [38;2;255;210;87;48;2;246;163;63m▄[48;2;169;103;58m [38;2;119;58;34m▄[48;2;246;163;63m [48;2;245;168;127m      [48;2;177;177;188m  [48;2;255;210;87m  [38;2;246;163;63;48;2;119;58;34m▄[48;2;169;103;58m▄[48;2;246;163;63m [48;2;192;98;89m [48;2;245;168;127m  [38;2;245;168;127;48;2;192;98;89m▄[38;2;192;98;89;48;2;245;168;127m▄[48;2;255;212;181m▄[38;2;245;168;127m▄[48;2;245;168;127m [48;2;31;18;19m   [48;2;55;33;16m [48;2;31;18;19m [49m                         [0m
                        [38;2;31;18;19m▄[38;2;55;33;16;48;2;31;18;19m▄▄   [48;2;236;123;94m [38;2;236;123;94;48;2;152;74;79m▄[38;2;192;98;89;48;2;52;49;54m▄[48;2;177;177;188m▄ [38;2;177;177;188;48;2;255;210;87m▄[38;2;246;163;63m▄[48;2;246;163;63m [38;2;236;123;94m▄[48;2;245;168;127m▄      [38;2;245;168;127;48;2;177;177;188m▄[38;2;236;123;94m▄[48;2;246;163;63m▄[38;2;192;98;89m▄▄[38;2;245;168;127;48;2;192;98;89m▄[48;2;245;168;127m   [38;2;192;98;89m▄[48;2;192;98;89m [38;2;245;168;127m▄[38;2;236;123;94;48;2;245;168;127m▄[38;2;192;98;89;48;2;236;123;94m▄[48;2;31;18;19m   [38;2;31;18;19;48;2;55;33;16m▄[38;5;0;48;2;31;18;19m▄[49m                         [0m
                        [48;2;31;18;19m [48;2;55;33;16m  [38;2;55;33;16;48;2;31;18;19m▄  [38;2;31;18;19;48;2;236;123;94m▄ [48;2;152;74;79m [48;2;236;123;94m [38;2;245;168;127;48;2;192;98;89m▄▄▄[48;2;236;123;94m  [38;2;192;98;89m▄[48;2;245;168;127m             [38;2;231;214;224m▄[38;2;177;177;188;48;2;231;214;224m▄[38;2;192;98;89;48;2;245;168;127m▄▄[38;2;231;214;224;48;2;192;98;89m▄▄[48;2;177;177;188m▄▄[38;2;177;177;188;48;2;31;18;19m▄[38;5;0m▄▄[49m                          [0m
                        [38;5;0;48;2;31;18;19m▄[38;2;31;18;19;48;2;55;33;16m▄  [38;2;62;66;73;48;2;31;18;19m▄    [48;2;192;98;89m [38;2;236;123;94;48;2;245;168;127m▄       [48;2;245;168;127m▄▄[38;2;192;98;89m▄[38;2;60;11;13m▄▄[48;2;236;123;94m▄[38;2;236;123;94;48;2;60;11;13m▄[48;2;245;168;127m   [48;2;231;214;224m  [48;2;177;177;188m  [48;2;231;214;224m   [38;2;177;177;188m▄[38;2;133;136;156;48;2;177;177;188m▄[48;2;133;136;156m  [49m▄                          [0m
                          [38;5;0;48;2;31;18;19m▄[48;2;55;33;16m▄▄[49m [48;2;31;18;19m▄   [38;2;133;136;156;48;2;192;98;89m▄[38;2;192;98;89;48;2;245;168;127m▄[38;2;236;123;94m▄  [38;2;245;168;127;48;2;236;123;94m▄[38;2;236;123;94;48;2;60;11;13m▄ [38;2;122;9;21m▄[48;2;122;9;21m [48;2;154;19;18m▄[38;2;236;123;94m▄[38;2;245;168;127;48;2;122;9;21m▄[48;2;236;123;94m▄[38;2;231;214;224;48;2;245;168;127m▄[38;2;177;177;188;48;2;231;214;224m▄[48;2;245;168;127m [48;2;231;214;224m   [38;2;231;214;224;48;2;177;177;188m▄[48;2;231;214;224m [48;2;177;177;188m▄[38;2;177;177;188;48;2;133;136;156m▄       [38;5;0m▄[49m                        [0m
                                [48;2;133;136;156m [38;2;177;177;188;48;2;31;18;19m▄▄[48;2;133;136;156m  [38;2;133;136;156;48;2;192;98;89m▄▄[38;2;109;61;65;48;2;236;123;94m▄[38;2;192;98;89;48;2;245;168;127m▄[38;2;236;123;94m▄▄   [38;2;192;98;89m▄[48;2;231;214;224m  [48;2;177;177;188m  [38;2;213;134;71;48;2;231;214;224m▄▄▄▄▄▄[38;2;133;136;156m▄[48;2;177;177;188m▄[48;2;133;136;156m   [38;5;0m▄▄[49m                          [0m
                              [38;2;133;136;156m▄[38;2;177;177;188;48;2;169;103;58m▄▄[48;2;133;136;156m [38;2;213;134;71;48;2;177;177;188m▄▄[48;2;133;136;156m▄▄[38;2;13;8;15;48;2;213;134;71m▄▄▄[38;2;192;98;89;48;2;109;61;65m▄[38;2;213;134;71m▄[48;2;231;214;224m▄    [48;2;231;214;224m▄[48;2;213;134;71m [38;2;169;103;58m▄▄[38;2;213;134;71;48;2;169;103;58m▄[38;2;246;163;63m▄▄▄[38;2;213;134;71m▄[48;2;213;134;71m [48;2;255;210;87m▄ [38;2;255;210;87;48;2;133;136;156m▄  [38;2;133;136;156;49m▄▄                         [0m
                              [48;2;169;103;58m [38;2;133;136;156;48;2;177;177;188m▄  [48;2;213;134;71m▄[38;2;213;134;71;48;2;13;8;15m▄   [48;2;213;134;71m [38;2;34;29;34m▄[38;2;231;214;224m▄[48;2;34;29;34m▄▄[48;2;177;177;188m [38;2;177;177;188;48;2;231;214;224m▄[38;2;213;134;71m▄[48;2;213;134;71m  [48;2;169;103;58m▄[38;2;246;163;63;48;2;213;134;71m▄[38;2;213;134;71;48;2;246;163;63m▄[38;2;119;58;34m▄[48;2;213;134;71m▄[38;2;146;77;47;48;2;119;58;34m▄[38;2;169;103;58m▄[48;2;146;77;47m [48;2;146;77;47m▄[38;2;213;134;71m▄[38;2;255;210;87;48;2;119;58;34m▄▄[38;2;133;136;156m▄[48;2;133;136;156m [38;5;0m▄[49m                          [0m
                           [38;2;169;103;58m▄▄[48;2;169;103;58m [38;2;146;77;47;48;2;119;58;34m▄[38;2;119;58;34;48;2;133;136;156m▄[38;2;177;177;188m▄▄ [48;2;213;134;71m [48;2;13;8;15m  [48;2;13;8;15m▄[48;2;213;134;71m▄[38;2;213;134;71;48;2;34;29;34m▄ [48;2;231;214;224m    [38;2;177;177;188;48;2;213;134;71m▄[38;2;169;103;58;48;2;246;163;63m▄▄▄[38;2;119;58;34;48;2;169;103;58m▄[38;2;213;134;71;48;2;119;58;34m▄[48;2;146;77;47m▄▄▄▄[38;2;169;103;58;48;2;213;134;71m▄[38;2;146;77;47m▄[38;2;119;58;34;48;2;169;103;58m▄[38;2;213;134;71;48;2;146;77;47m▄[38;2;255;210;87;48;2;119;58;34m▄[38;2;169;103;58;48;2;133;136;156m▄[49m                            [0m
                       [38;2;99;103;111m▄▄  [38;5;0;48;2;169;103;58m▄[38;2;146;77;47m▄[38;2;13;8;15;48;2;146;77;47m▄[48;2;169;103;58m [38;2;146;77;47m▄[48;2;133;136;156m   [38;2;78;11;22;48;2;213;134;71m▄[38;2;122;9;21;48;2;78;11;22m▄[38;2;34;29;34;48;2;213;134;71m▄[38;2;213;134;71;48;2;177;177;188m▄[48;2;231;214;224m▄[38;2;34;29;34;48;2;213;134;71m▄[38;2;213;134;71;48;2;34;29;34m▄[38;2;34;29;34;48;2;177;177;188m▄[38;2;177;177;188;48;2;231;214;224m▄▄[48;2;177;177;188m [38;2;146;77;47m▄[38;2;169;103;58;48;2;13;8;15m▄[38;2;13;8;15;48;2;119;58;34m▄[38;2;146;77;47m▄[48;2;169;103;58m [38;2;213;134;71;48;2;146;77;47m▄▄[38;2;246;163;63m▄[38;2;213;134;71m▄[38;2;246;163;63;48;2;119;58;34m▄[48;2;13;8;15m [38;2;146;77;47;48;2;169;103;58m▄[48;2;213;134;71m [48;2;169;103;58m▄[48;2;255;210;87m [38;2;255;210;87;48;2;213;134;71m▄[38;2;169;103;58;49m▄                           [0m
              [38;2;133;136;156m▄▄▄[48;2;99;103;111m [48;2;99;103;111m▄[38;2;99;103;111;49m▄  [48;2;133;136;156m [38;2;169;103;58m▄[38;2;213;134;71;48;2;99;103;111m▄[49m▄▄[38;2;169;103;58m▄[48;2;13;8;15m [48;2;169;103;58m [38;2;146;77;47m▄[48;2;133;136;156m   [38;2;78;11;22m▄[48;2;122;9;21m   [38;2;122;9;21;48;2;34;29;34m▄▄[48;2;13;8;15m [38;2;13;8;15;48;2;213;134;71m▄[38;2;231;214;224;48;2;177;177;188m▄[48;2;231;214;224m  [38;2;13;8;15;48;2;177;177;188m▄[48;2;146;77;47m▄[38;2;213;134;71m▄[38;2;169;103;58;48;2;13;8;15m▄[38;2;13;8;15;48;2;146;77;47m▄[48;2;169;103;58m [48;2;213;134;71m [38;2;169;103;58m▄ [48;2;169;103;58m [48;2;213;134;71m [48;2;169;103;58m [38;2;34;29;34;48;2;13;8;15m▄[38;2;146;77;47;48;2;169;103;58m▄[48;2;213;134;71m [48;2;146;77;47m [48;2;255;210;87m [38;2;213;134;71;48;2;169;103;58m▄[49m          [38;2;133;136;156m▄▄               [0m
            [38;2;177;177;188m▄▄[48;2;133;136;156m▄[38;2;133;136;156;48;2;177;177;188m▄ [38;2;177;177;188;48;2;133;136;156m▄[38;2;99;103;111m▄ [38;2;133;136;156;48;2;99;103;111m▄[38;2;169;103;58;49m▄[38;2;146;77;47;48;2;169;103;58m▄[38;2;213;134;71;48;2;119;58;34m▄[38;2;119;58;34;48;2;213;134;71m▄[38;2;34;29;34;48;2;119;58;34m▄[48;2;13;8;15m▄▄[48;2;52;49;54m [48;2;13;8;15m  [48;2;133;136;156m   [38;2;122;9;21;48;2;78;11;22m▄[48;2;154;19;18m  [38;2;78;11;22m▄▄▄[48;2;122;9;21m [38;2;122;9;21;48;2;13;8;15m▄[48;2;231;214;224m [38;2;177;177;188m▄▄[38;2;119;58;34;48;2;146;77;47m▄[48;2;169;103;58m▄[38;2;13;8;15m▄[48;2;146;77;47m▄[38;2;34;29;34;48;2;13;8;15m▄[48;2;146;77;47m [48;2;169;103;58m [48;2;146;77;47m▄[48;2;213;134;71m▄[48;2;169;103;58m▄[48;2;213;134;71m▄[48;2;169;103;58m▄[38;2;52;49;54;48;2;34;29;34m▄▄▄[48;2;13;8;15m▄ [38;2;13;8;15;49m▄[38;2;213;134;71m▄[38;2;169;103;58;48;2;255;210;87m▄▄ [38;2;255;210;87;49m▄▄▄ [38;2;99;103;111m▄[48;2;133;136;156m    [49m    [49m▄▄        [0m
            [38;5;0;48;2;177;177;188m▄[48;2;231;214;224m  [38;2;231;214;224;48;2;177;177;188m▄[38;2;177;177;188;48;2;133;136;156m▄ [38;2;231;214;224m▄[48;2;177;177;188m▄[48;2;231;214;224m [48;2;213;134;71m [38;2;213;134;71;48;2;146;77;47m▄[48;2;213;134;71m [38;2;34;29;34;48;2;119;58;34m▄[48;2;34;29;34m [48;2;52;49;54m [48;2;34;29;34m [48;2;52;49;54m [48;2;13;8;15m▄ [48;2;133;136;156m   [38;2;13;8;15;48;2;122;9;21m▄ [48;2;154;19;18m [38;2;122;9;21;48;2;78;11;22m▄   [38;2;78;11;22;48;2;122;9;21m▄[48;2;177;177;188m   [38;2;146;77;47;48;2;13;8;15m▄[38;2;169;103;58m▄[48;2;213;134;71m▄[38;2;146;77;47;48;2;169;103;58m▄[48;2;34;29;34m [38;2;34;29;34;48;2;13;8;15m▄  [48;2;13;8;15m▄[48;2;52;49;54m   [48;2;52;49;54m▄▄[38;2;52;49;54;48;2;34;29;34m▄▄[48;2;52;49;54m [48;2;213;134;71m [38;2;213;134;71;48;2;169;103;58m▄[38;2;169;103;58;48;2;88;50;42m▄▄[38;2;213;134;71;48;2;146;77;47m▄[38;2;169;103;58;48;2;213;134;71m▄[38;2;119;58;34;48;2;169;103;58m▄[38;2;99;103;111;48;2;119;58;34m▄[38;2;133;136;156;48;2;99;103;111m▄[48;2;133;136;156m  [38;2;99;103;111m▄[38;5;0m▄[49m    [48;2;133;136;156m  [48;2;99;103;111m [49m        [0m
             [38;5;0;48;2;177;177;188m▄[38;2;177;177;188;48;2;231;214;224m▄     [48;2;177;177;188m [38;2;169;103;58;48;2;213;134;71m▄[48;2;146;77;47m [48;2;213;134;71m [48;2;34;29;34m  [38;2;34;29;34;48;2;52;49;54m▄[38;2;52;49;54;48;2;34;29;34m▄[48;2;52;49;54m [48;2;34;29;34m [38;2;34;29;34;48;2;13;8;15m▄[48;2;133;136;156m    [48;2;13;8;15m [38;2;13;8;15;48;2;122;9;21m▄[38;2;133;136;156;48;2;154;19;18m▄[48;2;122;9;21m▄[38;2;122;9;21;48;2;78;11;22m▄▄▄[38;2;133;136;156;48;2;177;177;188m▄  [48;2;119;58;34m▄[38;2;13;8;15m▄[38;2;213;134;71;48;2;13;8;15m▄[38;2;169;103;58;48;2;34;29;34m▄  [48;2;13;8;15m  [48;2;34;29;34m [38;2;34;29;34;48;2;52;49;54m▄ [48;2;34;29;34m  [48;2;52;49;54m [48;2;52;49;54m▄[38;2;52;49;54;48;2;34;29;34m▄[48;2;213;134;71m [48;2;169;103;58m [38;2;88;50;42;48;2;213;134;71m▄▄[38;2;146;77;47m▄[38;2;169;103;58m▄[48;2;119;58;34m [48;2;99;103;111m [38;2;99;103;111;48;2;133;136;156m▄  [38;2;133;136;156;48;2;99;103;111m▄▄[49m▄[38;2;99;103;111m▄▄[38;2;133;136;156;48;2;99;103;111m▄[48;2;133;136;156m [48;2;99;103;111m▄ [38;5;0m▄[49m        [0m
               [38;5;0;48;2;133;136;156m▄[48;2;177;177;188m▄[38;2;133;136;156m▄ [38;2;177;177;188;48;2;231;214;224m▄[48;2;177;177;188m [38;2;146;77;47;48;2;169;103;58m▄[38;2;119;58;34;48;2;213;134;71m▄[38;2;169;103;58m▄[48;2;119;58;34m [48;2;34;29;34m      [48;2;13;8;15m [48;2;133;136;156m   [48;2;34;29;34m [38;2;34;29;34;48;2;13;8;15m▄[48;2;133;136;156m   [48;2;13;8;15m  [38;2;13;8;15;48;2;78;11;22m▄[38;2;78;11;22;48;2;133;136;156m▄[38;2;133;136;156;48;2;177;177;188m▄[38;2;119;58;34;48;2;146;77;47m▄[48;2;169;103;58m▄[38;2;13;8;15m▄[38;2;34;29;34;48;2;146;77;47m▄[48;2;34;29;34m   [48;2;13;8;15m  [48;2;34;29;34m [48;2;52;49;54m  [48;2;52;49;54m▄[48;2;34;29;34m [38;2;52;49;54m▄[48;2;52;49;54m [48;2;213;134;71m [48;2;169;103;58m [48;2;213;134;71m [38;2;213;134;71;48;2;169;103;58m▄[48;2;213;134;71m [48;2;119;58;34m [48;2;177;177;188m  [38;2;177;177;188;48;2;99;103;111m▄[38;2;99;103;111;48;2;133;136;156m▄▄[38;2;177;177;188m▄[38;2;231;214;224;48;2;99;103;111m▄▄[38;2;177;177;188m▄[38;2;231;214;224;48;2;177;177;188m▄[48;2;231;214;224m [48;2;177;177;188m [48;2;133;136;156m [38;5;0;48;2;99;103;111m▄[49m         [0m
                    [38;5;0;48;2;177;177;188m▄[48;2;133;136;156m▄[48;2;146;77;47m▄[38;2;146;77;47;48;2;169;103;58m▄▄[48;2;119;58;34m▄[38;2;119;58;34;48;2;13;8;15m▄[38;2;13;8;15;48;2;34;29;34m▄▄▄▄[38;5;0;48;2;13;8;15m▄[48;2;133;136;156m  [48;2;146;77;47m [48;2;13;8;15m [48;2;34;29;34m [48;2;13;8;15m [48;2;133;136;156m [48;2;13;8;15m [48;2;34;29;34m [38;2;13;8;15m▄▄[38;2;122;9;21;48;2;78;11;22m▄[38;2;78;11;22;48;2;133;136;156m▄   [38;2;133;136;156;48;2;13;8;15m▄[48;2;34;29;34m▄[38;2;13;8;15m▄▄[48;2;13;8;15m  [48;2;34;29;34m▄      [48;2;213;134;71m [48;2;169;103;58m [38;2;213;134;71;48;2;88;50;42m▄[38;2;169;103;58;48;2;146;77;47m▄[38;2;213;134;71;48;2;169;103;58m▄[48;2;119;58;34m [48;2;177;177;188m [48;2;231;214;224m [38;2;231;214;224;48;2;177;177;188m▄[48;2;99;103;111m▄[48;2;177;177;188m▄[48;2;231;214;224m  [38;2;133;136;156m▄[48;2;177;177;188m [48;2;231;214;224m [38;2;177;177;188m▄[48;2;133;136;156m [49m           [0m
                                 [48;2;146;77;47m [48;2;13;8;15m [48;2;34;29;34m [48;2;13;8;15m [48;2;34;29;34m [38;2;13;8;15;48;2;133;136;156m▄[48;2;34;29;34m  [48;2;13;8;15m [48;2;34;29;34m [48;2;122;9;21m [48;2;78;11;22m [38;2;122;9;21m▄[38;2;154;19;18;48;2;133;136;156m▄[38;2;78;11;22m▄      [38;2;231;214;224m▄[38;2;255;251;239;48;2;13;8;15m▄▄▄[38;5;0m▄▄▄[38;2;13;8;15;48;2;34;29;34m▄[38;2;119;58;34;48;2;213;134;71m▄[48;2;169;103;58m▄[38;2;169;103;58;48;2;88;50;42m▄[48;2;146;77;47m▄[38;2;213;134;71;48;2;119;58;34m▄[38;2;119;58;34;48;2;177;177;188m▄ [38;2;177;177;188;48;2;231;214;224m▄  [48;2;231;214;224m▄[38;2;133;136;156;48;2;177;177;188m▄[48;2;133;136;156m [48;2;177;177;188m▄[38;5;0m▄[49m             [0m
                               [38;2;34;29;34m▄[38;2;146;77;47;48;2;34;29;34m▄[48;2;146;77;47m  [48;2;13;8;15m▄[38;2;213;134;71;48;2;34;29;34m▄[38;2;146;77;47;48;2;213;134;71m▄▄▄[38;2;213;134;71;48;2;13;8;15m▄[38;2;169;103;58;48;2;34;29;34m▄[48;2;13;8;15m▄[48;2;122;9;21m [38;2;122;9;21;48;2;78;11;22m▄[48;2;154;19;18m  [48;2;78;11;22m  [38;2;78;11;22;48;2;133;136;156m▄[38;2;13;8;15m▄▄▄▄[48;2;255;251;239m▄▄[38;2;71;71;81m▄[49m       [38;5;0;48;2;13;8;15m▄[48;2;119;58;34m▄▄▄[49m [48;2;177;177;188m▄▄▄[49m                  [0m
                              [38;2;146;77;47m▄[38;2;34;29;34;48;2;146;77;47m▄[48;2;13;8;15m▄ [48;2;146;77;47m▄[38;2;13;8;15m▄[38;2;169;103;58;48;2;213;134;71m▄ [38;2;213;134;71;48;2;146;77;47m▄ [48;2;213;134;71m [38;2;13;8;15;48;2;169;103;58m▄▄[48;2;122;9;21m [48;2;154;19;18m   [48;2;78;11;22m   [38;2;40;17;21;48;2;13;8;15m▄[38;2;34;29;34m▄[48;2;34;29;34m  [48;2;13;8;15m [48;2;34;29;34m [48;2;177;157;143m [38;2;97;93;89;48;2;71;71;81m▄[49m                                [0m
                             [38;2;146;77;47m▄[38;2;34;29;34;48;2;146;77;47m▄[38;2;13;8;15;48;2;34;29;34m▄[38;2;34;29;34;48;2;13;8;15m▄[38;2;13;8;15;48;2;34;29;34m▄[38;2;34;29;34;48;2;13;8;15m▄[48;2;34;29;34m [38;2;133;136;156;48;2;13;8;15m▄[38;2;177;177;188;48;2;169;103;58m▄[38;2;231;214;224m▄[38;2;34;29;34m▄[38;2;13;8;15;48;2;34;29;34m▄[38;2;34;29;34;48;2;13;8;15m▄[48;2;34;29;34m [48;2;122;9;21m [48;2;154;19;18m   [48;2;78;11;22m  [38;2;40;17;21m▄[38;2;13;8;15;48;2;40;17;21m▄[48;2;34;29;34m   [38;2;34;29;34;48;2;13;8;15m▄[38;2;13;8;15;48;2;34;29;34m▄[38;2;128;117;101;48;2;177;157;143m▄ [38;2;97;93;89;48;2;71;71;81m▄[49m                               [0m
                            [48;2;146;77;47m [38;2;13;8;15;48;2;34;29;34m▄ [38;2;34;29;34;48;2;13;8;15m▄[38;2;13;8;15;48;2;34;29;34m▄[38;2;34;29;34;48;2;13;8;15m▄[38;2;13;8;15;48;2;34;29;34m▄[48;2;13;8;15m [38;2;177;177;188;48;2;133;136;156m▄[48;2;231;214;224m  [38;2;13;8;15;48;2;34;29;34m▄ [48;2;34;29;34m▄[38;2;34;29;34;48;2;13;8;15m▄[48;2;122;9;21m [38;2;78;11;22;48;2;154;19;18m▄[38;2;13;8;15m▄[38;2;146;77;47;48;2;122;9;21m▄[38;2;13;8;15;48;2;78;11;22m▄[48;2;40;17;21m▄[38;2;34;29;34;48;2;13;8;15m▄[48;2;34;29;34m     [48;2;13;8;15m [48;2;34;29;34m [48;2;177;157;143m [38;2;177;157;143;48;2;97;93;89m▄[38;2;71;71;81;49m▄                              [0m
                          [38;2;13;8;15m▄[48;2;13;8;15m [48;2;146;77;47m▄[48;2;213;134;71m▄▄[38;2;213;134;71;48;2;13;8;15m▄▄[38;2;13;8;15;48;2;34;29;34m▄[48;2;13;8;15m [48;2;133;136;156m [38;2;231;214;224;48;2;177;177;188m▄[48;2;231;214;224m  [48;2;13;8;15m [48;2;34;29;34m [48;2;13;8;15m [38;2;213;134;71;48;2;34;29;34m▄[38;2;146;77;47;48;2;13;8;15m▄▄▄[38;2;13;8;15;48;2;146;77;47m▄[38;2;34;29;34;48;2;13;8;15m▄[48;2;34;29;34m       [48;2;13;8;15m▄[38;2;13;8;15;48;2;34;29;34m▄[38;2;34;29;34;48;2;128;117;101m▄[48;2;177;157;143m [48;2;97;93;89m [49m                              [0m
                        [38;2;146;77;47m▄[48;2;13;8;15m  [38;2;213;134;71m▄[38;2;146;77;47;48;2;213;134;71m▄[38;2;13;8;15m▄[38;2;213;134;71;48;2;13;8;15m▄▄▄[38;2;146;77;47;48;2;213;134;71m▄[38;2;133;136;156;48;2;13;8;15m▄[48;2;133;136;156m [48;2;231;214;224m   [38;2;213;134;71;48;2;34;29;34m▄[38;2;13;8;15;48;2;213;134;71m▄[48;2;146;77;47m▄[48;2;13;8;15m   [38;2;213;134;71m▄[48;2;34;29;34m▄▄     [48;2;34;29;34m▄▄▄[48;2;13;8;15m [48;2;34;29;34m [48;2;177;157;143m [38;2;255;210;87;48;2;97;93;89m▄[49m▄                             [0m
                        [38;2;13;8;15;48;2;146;77;47m▄[38;2;146;77;47;48;2;13;8;15m▄[38;2;213;134;71m▄[38;2;13;8;15;48;2;213;134;71m▄[48;2;13;8;15m [38;2;34;29;34m▄[48;2;34;29;34m [38;2;213;134;71m▄▄[38;2;146;77;47;48;2;13;8;15m▄[38;2;78;11;22;48;2;40;17;21m▄[38;2;122;9;21;48;2;78;11;22m▄[48;2;40;17;21m [48;2;177;177;188m▄[38;2;78;11;22;48;2;231;214;224m▄[48;2;213;134;71m▄[38;2;40;17;21m▄[38;2;13;8;15m▄▄▄▄[38;2;34;29;34;48;2;146;77;47m▄[48;2;13;8;15m  [38;2;146;77;47;48;2;213;134;71m▄[38;2;213;134;71;48;2;34;29;34m▄▄▄[48;2;213;134;71m [38;2;13;8;15;48;2;146;77;47m▄[48;2;13;8;15m [38;2;146;77;47;48;2;213;134;71m▄[38;2;213;134;71;48;2;13;8;15m▄[48;2;34;29;34m▄[38;2;255;210;87;48;2;128;117;101m▄[48;2;255;210;87m [38;2;177;157;143;48;2;71;71;81m▄[38;2;71;71;81;49m▄                            [0m
                      [38;2;13;8;15m▄[48;2;13;8;15m   [48;2;34;29;34m  [48;2;13;8;15m [48;2;34;29;34m  [48;2;213;134;71m [38;2;146;77;47m▄[48;2;13;8;15m [38;2;122;9;21;48;2;78;11;22m▄[48;2;122;9;21m [48;2;40;17;21m [48;2;122;9;21m [48;2;78;11;22m  [48;2;122;9;21m [38;2;40;17;21;48;2;213;134;71m▄ [38;2;146;77;47m▄[48;2;34;29;34m   [48;2;13;8;15m [48;2;34;29;34m  [48;2;13;8;15m    [48;2;34;29;34m   [48;2;13;8;15m [48;2;34;29;34m [38;2;13;8;15;48;2;128;117;101m▄[48;2;177;157;143m [48;2;97;93;89m [49m                            [0m
                      [48;2;13;8;15m    [48;2;213;134;71m [38;2;13;8;15m▄[38;2;213;134;71;48;2;146;77;47m▄[48;2;34;29;34m▄▄[48;2;13;8;15m  [38;2;122;9;21;48;2;78;11;22m▄[48;2;122;9;21m  [48;2;78;11;22m [48;2;122;9;21m    [48;2;78;11;22m▄[38;2;34;29;34;48;2;146;77;47m▄[48;2;34;29;34m [38;2;213;134;71m▄▄ [38;2;34;29;34;48;2;13;8;15m▄[48;2;34;29;34m [38;2;213;134;71m▄▄[48;2;13;8;15m▄  [48;2;34;29;34m  [48;2;34;29;34m▄[48;2;13;8;15m▄[38;2;146;77;47;48;2;34;29;34m▄[48;2;13;8;15m [38;2;128;117;101;48;2;177;157;143m▄[38;2;255;210;87m▄[48;2;71;71;81m▄[49m                           [0m
                     [48;2;213;134;71m [38;2;13;8;15m▄[38;2;213;134;71;48;2;146;77;47m▄[48;2;13;8;15m▄[48;2;146;77;47m▄[38;2;13;8;15;48;2;213;134;71m▄[38;2;34;29;34;48;2;13;8;15m▄[48;2;34;29;34m [38;2;213;134;71m▄[48;2;146;77;47m▄[48;2;13;8;15m [38;2;78;11;22m▄[48;2;122;9;21m   [48;2;78;11;22m [48;2;122;9;21m     [38;2;40;17;21;48;2;213;134;71m▄[38;2;34;29;34m▄[48;2;13;8;15m▄ [38;2;146;77;47;48;2;213;134;71m▄[38;2;213;134;71;48;2;34;29;34m▄▄[48;2;213;134;71m [48;2;13;8;15m [38;2;13;8;15;48;2;146;77;47m▄[38;2;146;77;47;48;2;213;134;71m▄[38;2;213;134;71;48;2;13;8;15m▄[48;2;34;29;34m▄[48;2;213;134;71m [38;2;13;8;15;48;2;146;77;47m▄[48;2;13;8;15m [48;2;213;134;71m [38;2;213;134;71;48;2;13;8;15m▄[38;2;13;8;15;48;2;255;210;87m▄[38;2;128;117;101;48;2;177;157;143m▄[38;2;177;157;143;48;2;255;210;87m▄[38;2;71;71;81;49m▄                          [0m
                    [48;2;13;8;15m [38;2;13;8;15;48;2;146;77;47m▄[48;2;13;8;15m [48;2;34;29;34m  [48;2;34;29;34m▄[48;2;13;8;15m [48;2;34;29;34m  [48;2;146;77;47m▄[48;2;13;8;15m  [48;2;122;9;21m          [48;2;78;11;22m [48;2;213;134;71m [38;2;146;77;47m▄[48;2;34;29;34m  [48;2;13;8;15m  [48;2;34;29;34m  [48;2;13;8;15m    [48;2;34;29;34m   [48;2;13;8;15m [48;2;34;29;34m [48;2;13;8;15m  [48;2;177;157;143m [38;2;177;157;143;48;2;97;93;89m▄[38;2;71;71;81;49m▄                         [0m
                   [48;2;13;8;15m     [38;2;177;177;188;48;2;34;29;34m▄[38;2;231;214;224;48;2;13;8;15m▄▄[48;2;213;134;71m▄[38;2;177;177;188;48;2;146;77;47m▄[48;2;13;8;15m  [38;2;122;9;21;48;2;78;11;22m▄[48;2;122;9;21m      [48;2;78;11;22m [38;2;78;11;22;48;2;122;9;21m▄  [48;2;78;11;22m [48;2;40;17;21m▄[38;2;213;134;71;48;2;34;29;34m▄▄ [38;2;34;29;34;48;2;13;8;15m▄[48;2;34;29;34m   [48;2;13;8;15m▄   [48;2;34;29;34m    [48;2;13;8;15m [48;2;34;29;34m [48;2;13;8;15m [38;2;231;214;224;48;2;128;117;101m▄[48;2;231;214;224m [48;2;133;136;156m▄[38;2;133;136;156;49m▄                        [0m
                  [38;2;177;177;188m▄[48;2;177;177;188m [38;2;231;214;224m▄[48;2;231;214;224m        [38;2;177;177;188m▄[48;2;13;8;15m [38;2;78;11;22;48;2;122;9;21m▄     [48;2;78;11;22m   [48;2;122;9;21m  [48;2;78;11;22m  [38;2;177;177;188;48;2;213;134;71m▄[38;2;34;29;34;48;2;146;77;47m▄[48;2;34;29;34m       [48;2;13;8;15m  [48;2;34;29;34m   [38;2;231;214;224m▄[48;2;13;8;15m▄[38;2;177;177;188;48;2;34;29;34m▄[48;2;177;177;188m  [48;2;231;214;224m  [48;2;133;136;156m [49m                        [0m
                  [48;2;177;177;188m [48;2;231;214;224m  [38;2;177;177;188m▄[38;2;133;136;156m▄[38;2;13;8;15m▄▄▄▄[48;2;177;177;188m▄▄[38;2;133;136;156;48;2;13;8;15m▄▄[48;2;133;136;156m  [48;2;40;17;21m▄[48;2;78;11;22m▄[38;2;13;8;15m▄[48;2;122;9;21m▄[38;2;40;17;21;48;2;78;11;22m▄▄ [38;2;78;11;22;48;2;122;9;21m▄ [48;2;78;11;22m  [48;2;177;177;188m   [38;2;231;214;224;48;2;34;29;34m▄▄▄▄▄▄▄[48;2;231;214;224m       [48;2;177;177;188m   [38;2;133;136;156;48;2;231;214;224m▄[38;5;0;48;2;133;136;156m▄[49m                        [0m
                   [38;5;0;48;2;177;177;188m▄[48;2;133;136;156m▄▄        [48;2;133;136;156m▄▄▄[49m  [48;2;13;8;15m [38;2;34;29;34m▄▄▄▄    [38;2;44;46;52;48;2;133;136;156m▄[48;2;177;177;188m  [48;2;231;214;224m  [38;2;177;177;188m▄         [48;2;231;214;224m▄[38;2;133;136;156;48;2;177;177;188m▄▄[38;5;0m▄[48;2;133;136;156m▄[49m                          [0m
                              [38;2;44;46;52m▄▄▄[38;2;34;29;34;48;2;44;46;52m▄▄[38;2;52;49;54;48;2;34;29;34m▄▄▄▄ [48;2;13;8;15m [48;2;34;29;34m [48;2;13;8;15m  [38;2;13;8;15;48;2;44;46;52m▄[38;2;44;46;52;48;2;133;136;156m▄[48;2;177;177;188m▄[38;2;133;136;156m▄[48;2;231;214;224m▄[38;2;177;177;188m▄[48;2;177;177;188m  [48;2;231;214;224m▄[38;2;13;8;15m▄▄▄[48;2;177;177;188m▄▄[48;2;133;136;156m▄[38;2;44;46;52;48;2;34;29;34m▄[49m▄▄▄                           [0m
                          [38;2;44;46;52m▄▄[48;2;44;46;52m  [38;2;34;29;34m▄[38;2;52;49;54m▄[48;2;34;29;34m▄[48;2;52;49;54m  [38;2;34;29;34m▄▄[38;2;13;8;15;48;2;34;29;34m▄[38;2;34;29;34;48;2;13;8;15m▄▄[38;2;13;8;15;48;2;34;29;34m▄[48;2;13;8;15m   [38;2;90;52;34m▄[48;2;44;46;52m    [48;2;13;8;15m     [38;2;34;29;34m▄▄▄[48;2;34;29;34m [48;2;13;8;15m [48;2;44;46;52m      [38;2;44;46;52;49m▄▄                       [0m
                       [38;2;44;46;52m▄[48;2;44;46;52m     [38;2;90;52;34;48;2;34;29;34m▄[38;2;116;72;34;48;2;52;49;54m▄▄[38;2;34;29;34m▄▄[38;2;13;8;15;48;2;34;29;34m▄[38;2;34;29;34;48;2;13;8;15m▄▄[38;2;13;8;15;48;2;34;29;34m▄[48;2;13;8;15m    [38;2;90;52;34m▄[48;2;90;52;34m  [38;2;31;31;42;48;2;44;46;52m▄▄▄▄[48;2;13;8;15m   [48;2;34;29;34m [48;2;13;8;15m [48;2;34;29;34m [38;2;52;49;54m▄▄▄[38;2;34;29;34;48;2;13;8;15m▄[38;2;13;8;15;48;2;34;29;34m▄[38;2;34;29;34;48;2;44;46;52m▄        [38;2;44;46;52;49m▄                    [0m
                      [38;2;44;46;52m▄[48;2;44;46;52m      [38;2;31;31;42;48;2;90;52;34m▄ [38;2;90;52;34;48;2;116;72;34m▄▄▄[48;2;90;52;34m [48;2;13;8;15m▄  [48;2;13;8;15m▄▄[38;2;31;31;42;48;2;90;52;34m▄▄▄▄[48;2;31;31;42m     [48;2;90;52;34m [38;2;90;52;34;48;2;13;8;15m▄  [38;2;13;8;15;48;2;34;29;34m▄[38;2;34;29;34;48;2;13;8;15m▄[38;2;13;8;15;48;2;34;29;34m▄[48;2;52;49;54m   [38;2;52;49;54;48;2;34;29;34m▄[48;2;13;8;15m [48;2;34;29;34m [48;2;44;46;52m        [38;2;44;46;52;49m▄                   [0m
                      [48;2;44;46;52m        [38;2;44;46;52;48;2;31;31;42m▄▄ [38;2;31;31;42;48;2;90;52;34m▄▄▄▄▄[48;2;31;31;42m           [48;2;90;52;34m▄  [48;2;13;8;15m  [38;2;13;8;15;48;2;34;29;34m▄[38;2;34;29;34;48;2;13;8;15m▄[38;2;13;8;15;48;2;34;29;34m▄[38;2;116;72;34;48;2;52;49;54m▄▄[48;2;34;29;34m▄▄[38;2;90;52;34;48;2;13;8;15m▄[48;2;34;29;34m [48;2;44;46;52m        [49m                   [0m
                       [48;2;44;46;52m                      [38;2;44;46;52;48;2;31;31;42m▄▄▄▄▄▄ [38;2;31;31;42;48;2;90;52;34m▄[38;2;90;52;34;48;2;13;8;15m▄▄[48;2;90;52;34m [48;2;116;72;34m▄▄▄▄[48;2;90;52;34m   [48;2;44;46;52m       [49m                    [0m
                        [38;5;0;48;2;44;46;52m▄▄                          [38;2;44;46;52;48;2;31;31;42m▄▄ [38;2;31;31;42;48;2;90;52;34m▄▄▄▄▄▄▄[38;2;44;46;52;48;2;31;31;42m▄[48;2;44;46;52m    [38;5;0m▄▄[49m                     [0m
                            [38;5;0;48;2;44;46;52m▄▄                                 [48;2;44;46;52m▄▄[49m                         [0m
                                 [38;5;0;48;2;44;46;52m▄▄▄▄▄▄               [48;2;44;46;52m▄▄▄▄▄▄[49m                              [0m
                                                                                          [0m
                                                                                          [0m
                                    Welcome to emet-selch!
                      "But come! Let us cast aside titles and pretense, 
                       and reveal our true faces to one another! I am
                          Hades! He who shall awaken our brethren 
                                  from their dark slumber!"
    '';

    time.timeZone = "Europe/Paris";

    users.users.${config.navi.username}.initialHashedPassword = fileContents ./../../secrets/emet-selch/assets/shadow/main;

    # Network (Hetzner uses static IP assignments, and we don't use DHCP here)
    networking.useDHCP = false;
    networking.interfaces."enp0s31f6".ipv4.addresses = [
      {
        address = "95.216.240.149";
        # FIXME: The prefix length is commonly, but not always, 24.
        # You should check what the prefix length is for your server
        # by inspecting the netmask in the "IPs" tab of the Hetzner UI.
        # For example, a netmask of 255.255.255.0 means prefix length 24
        # (24 leading 1s), and 255.255.255.192 means prefix length 26
        # (26 leading 1s).
        prefixLength = 24;
      }
    ];
    networking.interfaces."enp0s31f6".ipv6.addresses = [
      {
        address = "2a01:4f9:2b:22c1::1";
        prefixLength = 64;
      }
    ];
    networking.defaultGateway = "95.216.240.129";
    networking.defaultGateway6 = { address = "fe80::1"; interface = "enp0s31f6"; };
    networking.nameservers = [ "8.8.8.8" ];


    navi.profile.name = "server";
  };
}
