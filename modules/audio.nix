{ ... }:

{
  # -----------------------------------------------------------------
  # PipeWire — stack de áudio principal
  # PulseAudio desabilitado para evitar conflito.
  # -----------------------------------------------------------------
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;  # necessário para Steam/Wine/jogos 32-bit
    pulse.enable = true;       # compatibilidade PulseAudio
    # jack.enable = true;      # habilitar se houver produção musical/JACK
  };
}
