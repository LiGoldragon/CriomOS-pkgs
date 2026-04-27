{
  description = "CriomOS-pkgs — instantiates nixpkgs for one (nixpkgs-rev, system) tuple, with CriomOS's overlays applied. Consumed by CriomOS as a flake input; living in its own repo means CriomOS source edits don't invalidate the pkgs eval cache. The expensive `import nixpkgs { ... }` is keyed only on (nixpkgs.narHash, system.narHash, overlays-content), so it caches across CriomOS iteration.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    system.url = "path:./stubs/no-system";
  };

  outputs = { self, nixpkgs, system }: {
    pkgs = import nixpkgs {
      system = system.system;
      config.allowUnfree = true;
      overlays = [
        # openldap's syncreplication self-tests (test017 / test018) rely
        # on `sleep 7` for the consumer slapd to catch up — flakes under
        # any build-host load. nixpkgs CI hits the same flake (NixOS/
        # nixpkgs#440594 closed as not planned, #372569). The package
        # binary itself is fine; only the build-time test phase is
        # timing-sensitive. Skip checks to make local builds
        # deterministic. openldap appears in our closure via bottles'
        # multiPkgs (wine LDAP support).
        (_: prev: {
          openldap = prev.openldap.overrideAttrs (_: { doCheck = false; });
        })

        # SpamAssassin 4.0.1's test suite fails 3/216 programs (3/3673
        # subtests) — DNS / network-dependent tests that can't pass in
        # the nix sandbox. Hits us via the evolution → dbus → mail-stack
        # closure that lands on every node with a dbus system bus. The
        # package binary itself is fine; only the build-time test phase
        # is brittle. Re-evaluate when nixpkgs unbreaks the suite (same
        # mechanism as openldap).
        (_: prev: {
          spamassassin = prev.spamassassin.overrideAttrs (_: { doCheck = false; });
        })
      ];
    };
  };
}
