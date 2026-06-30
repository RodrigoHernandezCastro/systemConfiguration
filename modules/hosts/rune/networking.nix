{
  flake.nixosModules.networking =
    {
      ...
    }:
    {
      networking = {
        hostName = "rune";
        networkmanager.enable = true;

        # ── DNS: use Google + Cloudflare, bypass broken router DNS ──
        nameservers = [
          "8.8.8.8"
          "1.1.1.1"
        ];
        networkmanager.dns = "none";

        # ── Disable IPv6 (no IPv6 connectivity) ──
        enableIPv6 = false;

        # ── Allow ping responses (for diagnostics) ──
        firewall.allowPing = true;
      };

      # ── Kernel TCP tuning for low-latency gaming ──
      boot.kernel.sysctl = {
        # Bufferbloat: fq_codel (already default, made explicit)
        "net.core.default_qdisc" = "fq_codel";

        # TCP BBR congestion control — better throughput under packet loss
        "net.ipv4.tcp_congestion_control" = "bbr";

        # Reduce buffer sizes to minimize latency under load
        "net.core.rmem_default" = 262144;
        "net.core.wmem_default" = 262144;
        "net.core.rmem_max" = 16777216;
        "net.core.wmem_max" = 16777216;

        # TCP fast open (client + server)
        "net.ipv4.tcp_fastopen" = 3;

        # Reduce TIME_WAIT sockets
        "net.ipv4.tcp_tw_reuse" = 1;

        # Keepalive tuning
        "net.ipv4.tcp_keepalive_time" = 60;
        "net.ipv4.tcp_keepalive_intvl" = 10;
        "net.ipv4.tcp_keepalive_probes" = 6;

        # Backlog tuning
        "net.core.somaxconn" = 4096;
        "net.ipv4.tcp_max_syn_backlog" = 4096;

        # Disable slow start after idle (keep connections responsive)
        "net.ipv4.tcp_slow_start_after_idle" = 0;

        # Low latency polling
        "net.core.busy_poll" = 50;
        "net.core.busy_read" = 50;

        # Prevent router from redirecting
        "net.ipv4.conf.all.accept_redirects" = 0;
        "net.ipv4.conf.all.send_redirects" = 0;
      };
    };
}
