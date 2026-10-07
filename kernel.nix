{ config, pkgs, ... }:

{
  # Configurações extras de kernel para AMD
  boot.kernelParams = [
    "amdgpu.ppfeaturemask=0xffffffff" # habilita controle de clock/voltagem via amdgpu
    "amd_pstate=active"               # scheduler de CPU para AMD Ryzen (se aplicável)
  ];

  # Módulos de kernel carregados na inicialização
  boot.initrd.kernelModules = [ "amdgpu" ];

  # Módulos extras disponíveis
  boot.extraModulePackages = [ ];
}
