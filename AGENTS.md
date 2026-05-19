BORA NixOS - AgentiC Rules and Sprint Definitions
Strict-Hard - Zero Hardcoding - Zero Comments - Zero Inline Shell
Version 2.0.0 - Sprint: Fondazione


INDICE

1. Architettura del Repository
2. Regole Assolute
3. Parametrizzazione - Zero Hardcoding
4. Sprint Definitions
5. Spring Framework - Specifica Tecnica
6. Resource Management e Circuit Breaker
7. Security Baseline
8. Idempotenza e Atomicita
9. Testing e Quality Gates
10. Flow Operativo Agente


1. ARCHITETTURA DEL REPOSITORY

Albero Directory:

os/
  flake.nix                    ENTRY POINT - stateless, pure
  configuration.nix            MODULE LOADER - auto-scan dinamico
  AGENTS.md                    QUESTO FILE - regole agentiche + sprint
  lib/                         NIX LIBRARIES - funzioni pure
    default.nix                Esporta tutte le librerie
    hardware.nix               Auto-detection CPU/GPU/Platform
    spring.nix                 DI/IoC Container + Circuit Breaker
  src/                         NIXOS SOURCE - tutto il codice Nix
    hosts/                     HOST DEFINITIONS - per-macchina
      <hostname>/              Esempio: os, bora, server
        meta.nix               Metadati: system, hardware, profile, username
        default.nix            Config host-specific (user, shell, sudo)
        hardware.nix           Hardware scan (generato da nixos-generate-config)
    profiles/                  PROFILE DEFINITIONS - use-case
      workstation.nix          Desktop + KDE + Bora layout
      developer.nix            Workstation + Dev tools
      server.nix               Headless + Container orchestrator
      minimal.nix              Headless minimale
    modules/                   MODULES - organizzati per categoria
      core/                    Boot, Nix, Locale, Sysctl
      filesystem/              ZFS, Impermanence
      security/                Firewall, Hardening, SSH
      containers/              MicroVM Host, Orchestrator, Instance Pool
      desktop/                 KDE Minimal, PipeWire, Bora layout
      hardware/                CPU, GPU, Platform
      network/                 Base, DNS
    guests/                    MICROVM GUESTS - definizioni container
      example/                 Generic instance definition + pool config
      sandbox.nix              Template sandbox generico
  config/                      RUNTIME CONFIG - file di configurazione
    desktop/                   plasma-appletsrc, kdeglobals, kwinrc, khotkeysrc
    containers/                microvm-bridge.nix
    security/                  nftables.nix (rule set nft)
  assets/                      STATIC ASSETS - wallpapers, themes, fonts, icons
    wallpapers/
    themes/
    fonts/
    icons/
  scripts/                     SHELL SCRIPTS - mai inline nei .nix
    spring/                    cgroup-init, circuit-breaker, healthcheck, bean-wrapper
    maclike/                   init-desktop, finalize
    pool/                      pool-manager, spawn, list, stats
  secrets/                     ENCRYPTED SECRETS - SOPS + age
  tests/                       NIX TESTS - valutazioni pure
    default.nix                Test esecuzione lib
    shell.nix                  Ambiente test (statix, deadnix, nixpkgs-fmt)
  docs/                        DOCUMENTAZIONE
    BORA-WP.md             Manuale utente - formato testo

Principi Architetturali:

Single Responsibility: ogni file .nix ha UN SOLO scopo. Un file = un modulo = una funzione.
No Side Effects: le funzioni in lib/ sono pure. Nessun effetto collaterale.
Auto-Discovery: configuration.nix scansiona src/modules/ - nessun import manuale.
Parametrizzazione: tutto via options + mkOption. Niente hardcoded.
External Shell: script shell in scripts/. Riferiti via builtins.readFile.
External Config: file config in config/. Riferiti via path relativo.


2. REGOLE ASSOLUTE

REGOLA 1: ZERO COMMENTS IN NIX FILES

VIETATO: # commento inline
VIETATO: /* commento a blocchi */
VIETATO: /* ... */ multilinea

DOVUNQUE: documentazione in AGENTS.md
DOVUNQUE: documentazione utente in docs/*.md

ECCEZIONE: SOLO AGENTS.md e docs/*.md possono contenere testo

REGOLA 2: ZERO SHELL INLINE IN NIX

VIETATO: script shell dentro '' ... ''
VIETATO: pkgs.writeShellScript "nome" '' ... ''
VIETATO: ''${...} con comandi shell

OBBLIGO: ogni script shell in scripts/ come file separato
RIFERIMENTO: builtins.readFile ./scripts/path.sh

CORRETTO: pkgs.writeShellScriptBin "name" (builtins.readFile ./scripts/name.sh)

REGOLA 3: ZERO HARDCODING

VIETATO: hardcodare username (alessio, kairosci, ...)
VIETATO: hardcodare hostname (bora, os, ...)
VIETATO: hardcodare path, IP, porte, UUID
VIETATO: hardcodare CPU/GPU/RAM config

OBBLIGO: username da meta.nix o option
OBBLIGO: hostname da meta.nix o option
OBBLIGO: hardware con opzioni lib.mkDefault
OBBLIGO: attivazione con lib.mkIf

REGOLA: Niente letterale. Ogni valore e una variabile.

REGOLA 4: ATOMICITA STRUTTURALE

OBBLIGO: ogni modifica produce un NEW GENERATION atomico

VIETATO: workaround, fallback, placeholders
VIETATO: # TODO:, # FIXME:, # HACK:
VIETATO: commenti per disabilitare codice

CORRETTO: mkIf false per disabilitare un modulo
CORRETTO: funzione non implementata = NON ESISTE

REGOLA 5: MODULARITA DINAMICA

configuration.nix scansiona src/modules/ AUTOMATICAMENTE.
Ogni categoria = src/modules/<categoria>/.
Ogni categoria ha default.nix che importa sottomoduli.

Moduli si abilitano via mkIf cfg.enable.
Profili attivano combinazioni di moduli.

NEW MODULE FLOW:
1. Crea src/modules/<categoria>/<nome>.nix
2. Aggiorna src/modules/<categoria>/default.nix
3. Definisci options con enable + parametri
4. Usa mkIf cfg.enable per la config


3. PARAMETRIZZAZIONE - ZERO HARDCODING

Tutti i parametri host-specific sono DICHIARATI in src/hosts/<hostname>/meta.nix
e INIETTATI via specialArgs.

meta.nix - Template Generico:

{ system = "x86_64-linux"; hardware = "desktop"; profile = "developer"; hostname = "os"; username = "user"; }

Regole di Sostituzione:

Cosa                  Dove                    Come
username              users.users.*           Diventa ${username}
username              /home/*                 Diventa /home/${username}
hostname              networking.hostName     Diventa ${hostname}
hostname              spring.application.name Diventa ${hostname}
/persist              environment.persistence Legge da option
Path assoluti         config/ e scripts/      Path relativi sempre


4. SPRINT DEFINITIONS

Sprint 1 - Fondazione (Foundation)

SCOPO: Struttura base del sistema funzionante

1.1 flake.nix - Entry point puro con inputs dichiarativi
1.2 configuration.nix - Module loader auto-scan
1.3 lib/default.nix - Esporta tutte le librerie
1.4 lib/hardware.nix - Database CPU/GPU/Platform
1.5 src/modules/core/ - Boot, Nix, Locale, Sysctl
1.6 src/hosts/<hostname>/ - Meta + default + hardware
1.7 AGENTS.md - Questo file

Sprint 2 - Filesystem e Immutabilita

SCOPO: ZFS + Impermanence + Disko

2.1 src/modules/filesystem/zfs.nix - Pool, ARC, snapshot
2.2 src/modules/filesystem/impermanence.nix - /persist
2.3 config/desktop/ - Config file esterni (plasma, nft)
2.4 sanoid - Snapshot retention automatica
2.5 disko - Partizionamento dichiarativo

Sprint 3 - Sicurezza

SCOPO: Hardening estremo + Firewall + SSH

3.1 src/modules/security/firewall.nix - nftables default drop
3.2 config/security/nftables.nix - Ruleset esterno
3.3 src/modules/security/hardening.nix - Kernel + AppArmor
3.4 src/modules/security/ssh.nix - Only keys, only LAN
3.5 Audit logging + fail2ban

Sprint 4 - Hardware Detection

SCOPO: Auto-configurazione CPU/GPU/Platform

4.1 src/modules/hardware/cpu.nix - Intel/AMD/ARM
4.2 src/modules/hardware/gpu.nix - NVIDIA/AMD/Intel
4.3 src/modules/hardware/platform.nix - Desktop/Laptop/Server
4.4 lib/hardware.nix - Database ottimizzazioni per vendor

Sprint 5 - Desktop e Bora Layout

SCOPO: KDE Plasma 6 minimale con layout Bora originale

5.1 src/modules/desktop/kde-minimal.nix - Plasma 6 essenziale
5.2 src/modules/desktop/bora.nix - Tema, dock, global menu
5.3 src/modules/desktop/pipewire.nix - Audio
5.4 scripts/bora/ - Init + finalize shell scripts
5.5 config/desktop/ - plasma-appletsrc, kdeglobals, kwinrc

Sprint 6 - Container Engine (MicroVM)

SCOPO: Container engine con isolamento hardware-level

6.1 src/modules/containers/microvm-host.nix - Host + bridge
6.2 src/modules/containers/orchestrator.nix - Pool manager
6.3 src/guests/sandbox.nix - Guest template generico
6.4 config/containers/ - Config bridge e networking
6.5 SocketVM per app desktop con forwarding X11/Wayland

Sprint 7 - Spring Framework (DI/IoC)

SCOPO: Dependency Injection + Circuit Breaker

7.1 lib/spring.nix - Bean definitions + topological sort
7.2 lib/spring.nix - mkSystemdService con resource limits
7.3 lib/spring.nix - Circuit breaker (failure/success/stato)
7.4 lib/spring.nix - Circular dependency detection
7.5 scripts/spring/ - cgroup-init, circuit-breaker, health
7.6 Aggiornare orchestrator per usare Spring beans

Sprint 8 - Instance Pool Orchestrator

SCOPO: Pool di istanze isolate per qualsiasi applicazione

8.1 src/modules/containers/instance-pool.nix - Opzioni pool
8.2 src/guests/<app>/guest.nix - Guest definition
8.3 src/guests/<app>/pool.nix - Pool configuration
8.4 scripts/pool/ - pool-manager, spawn, list, stats
8.5 Cgroup v2 per isolamento risorse per istanza
8.6 Reverse proxy Caddy per routing alle istanze

Sprint 9 - Testing e Documentazione

SCOPO: Test Nix puri + Documentazione completa

9.1 tests/default.nix - Test librerie pure
9.2 tests/shell.nix - Ambiente linting (statix, deadnix)
9.3 docs/BORA-WP.md - Manuale utente formato testo
9.4 AGENTS.md - Regole agentiche sempre aggiornate
9.5 ISO generation per deploy immediato

Sprint Flow:

Sprint 1 -> Sprint 2 -> Sprint 3 -> Sprint 4
                                      |
                                      v
                                 Sprint 5
                                      |
                                      v
                                 Sprint 6
                                      |
                                      v
                       Sprint 7 -> Sprint 8 -> Sprint 9

Ogni sprint produce una generazione NixOS funzionante. Nessuna dipendenza non soddisfatta.

Sprint History:

SPRINT 1 - Fondazione - COMPLETATO
  1.1 flake.nix - COMPLETATO
  1.2 configuration.nix - COMPLETATO
  1.3 lib/default.nix - COMPLETATO
  1.4 lib/hardware.nix - COMPLETATO
  1.5 src/modules/core/ - COMPLETATO
  1.6 src/hosts/os/ - COMPLETATO
  1.7 AGENTS.md - COMPLETATO

SPRINT 2 - Filesystem e Immutabilita - COMPLETATO
  2.1 zfs.nix - COMPLETATO
  2.2 impermanence.nix - COMPLETATO
  2.3 config/desktop/ - COMPLETATO
  2.4 sanoid - COMPLETATO
  2.5 disko - COMPLETATO

SPRINT 3 - Sicurezza - COMPLETATO
  3.1 firewall.nix - COMPLETATO
  3.2 nftables config - COMPLETATO
  3.3 hardening.nix - COMPLETATO
  3.4 ssh.nix - COMPLETATO
  3.5 fail2ban + audit - COMPLETATO

SPRINT 4 - Hardware Detection - COMPLETATO
  4.1 cpu.nix - COMPLETATO
  4.2 gpu.nix - COMPLETATO
  4.3 platform.nix - COMPLETATO
  4.4 lib/hardware.nix - COMPLETATO

SPRINT 5 - Desktop e Bora Layout - COMPLETATO
  5.1 kde-minimal.nix - COMPLETATO
  5.2 maclike.nix (Bora theme) - COMPLETATO
  5.3 pipewire.nix - COMPLETATO
  5.4 scripts/maclike/ - COMPLETATO
  5.5 config/desktop/ - COMPLETATO

SPRINT 6 - Container Engine - COMPLETATO
  6.1 microvm-host.nix - COMPLETATO
  6.2 orchestrator.nix - COMPLETATO
  6.3 sandbox.guest - COMPLETATO
  6.4 container config - COMPLETATO
  6.5 SocketVM forwarding - COMPLETATO

SPRINT 7 - Spring Framework - COMPLETATO
  7.1 bean definitions - COMPLETATO
  7.2 systemd services - COMPLETATO
  7.3 circuit breaker - COMPLETATO
  7.4 cycle detection - COMPLETATO
  7.5 spring scripts - COMPLETATO

SPRINT 8 - Instance Pool - COMPLETATO
  8.1 instance-pool.nix - COMPLETATO
  8.2 guest definition - COMPLETATO
  8.3 pool config - COMPLETATO
  8.4 pool scripts - COMPLETATO
  8.5 cgroup v2 - COMPLETATO
  8.6 Caddy proxy - COMPLETATO

SPRINT 9 - Testing e Documentazione - COMPLETATO
  9.1 tests/default.nix - COMPLETATO
  9.2 tests/shell.nix - COMPLETATO
  9.3 docs/BORA-WP.md - COMPLETATO
  9.4 AGENTS.md - COMPLETATO
  9.5 ISO generation - COMPLETATO

Tutti gli sprint sono COMPLETATI. Il sistema e pronto per build e deploy.


5. SPRING FRAMEWORK - SPECIFICA TECNICA

Bean Definition:

bora.spring.beans.<name> = {
  enable = true;
  class = "ServiceType";
  deps = [ "bean-a" "bean-b" ];
  resources = {
    cpu = "2";
    memory = "1G";
    memoryMax = "2G";
    pids = 512;
    ioRbps = "100M";
    ioWbps = "50M";
    numa = null;
  };
  healthcheck = "curl -f http://localhost:8080";
  dependsOn = [ "storage" ];
  after = [ "network.target" ];
  restartPolicy = "on-failure";
};

Circuit Breaker state machine:

CLOSED: funzionamento normale, richieste passano, failure incrementano contatore.
OPEN: circuito aperto, richieste bloccate, timer di timeout avviato.
HALF-OPEN: test di recupero, richieste limitate.

Transizioni:
  CLOSED -> OPEN: quando failure >= threshold (default 5)
  OPEN -> HALF-OPEN: dopo timeout (default 30 secondi)
  HALF-OPEN -> CLOSED: quando success >= threshold (default 2)
  HALF-OPEN -> OPEN: quando failure in half-open

Topological Sort:

Le dipendenze tra bean sono risolte a BUILD-TIME con topological sort.
Se esiste un ciclo, il build FAIL con messaggio:
error: Spring: circular dependency detected in beans: [a, b, c]


6. RESOURCE MANAGEMENT E CIRCUIT BREAKER

Cgroup v2 Hierarchy:

/sys/fs/cgroup/
  <hostname>/
    bean-database/             cpu.max, memory.max, pids.max, io.max
    bean-redis/                Limiti dedicati per bean
    bean-webapp/               OOM policy: kill
  bora/
    pool/                      Pool istanze MicroVM
      instance-001/            cpu.max=50%, memory.max=256M
      instance-002/            cpu.max=50%, memory.max=256M

OOM Protection:

OOMPolicy=kill per tutti i servizi Spring.
MemoryHigh = soft limit (throttling prima di OOM).
MemoryMax = hard limit (OOM kill se superato).
DefaultMemoryAccounting=yes globalmente.

Health Check Flow:

1. Esegui healthcheck command
2. Se SUCCESS -> circuit_success()
3. Se FAILURE -> circuit_trip()
   CLOSED: incrementa counter, se > threshold -> OPEN
   OPEN: attendi timeout, poi -> HALF-OPEN
   HALF-OPEN: se < max tentativi -> riprova, altrimenti -> CLOSED
4. Se circuito OPEN -> servizio non parte (exit 1)


7. SECURITY BASELINE

Kernel Parameters (sysctl):

kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
kernel.perf_event_paranoid = 3
kernel.yama.ptrace_scope = 2
kernel.randomize_va_space = 2
kernel.unprivileged_bpf_disabled = 1
net.core.bpf_jit_enable = 0
kernel.kexec_load_disabled = 1
kernel.sysrq = 0

Firewall (nftables):

chain input -> policy DROP
  ct state { established, related } -> ACCEPT
  iifname lo -> ACCEPT
  icmp -> rate 10/second ACCEPT
  tcp 22 -> saddr LAN -> ACCEPT
  tutto altro -> LOG + DROP

chain forward -> policy DROP
  ct state { established, related } -> ACCEPT
  iifname "microvm" -> ACCEPT

chain output -> policy ACCEPT

SSH Hardening:

PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
MaxAuthTries 3
MaxSessions 4
AllowTcpForwarding no
AllowAgentForwarding no
Ciphers chacha20-poly1305, aes256-gcm
MACs hmac-sha2-512-etm, hmac-sha2-256-etm

AppArmor:

Enforced con cache attiva. Profili: apparmor-profiles.
Lockdown: confidentiality.


8. IDEMPOTENZA E ATOMICITA

Regole di Idempotenza:

nixos-rebuild switch DEVE essere IDEMPOTENTE.
Eseguire 2 volte di seguito -> stesso risultato.
Niente side effects fuori dal nix store.
/etc rigenerato a ogni build.
Stato utente SOLO in /persist e /home.
Root filesystem effimero (impermanence).

Atomicita:

Ogni nixos-rebuild produce una NEW GENERATION.
La generazione precedente rimane INTATTA nel boot menu.
Rollback: nixos-rebuild switch --rollback.
ZFS: snapshot automatico PRE-rebuild.
ZFS: snapshot POST-rebuild via sanoid.

farlo, tentativo, hack, workaround = ZERO TOLERANZA.


9. TESTING E QUALITY GATES

Quality Gates (obbligatori prima di ogni commit):

1. statix check src/ - Linting Nix
2. deadnix src/ - Dead code detection
3. nixpkgs-fmt --check src/ - Formattazione
4. nix-instantiate --eval tests/ - Valutazione test

FALLISCI se UNO qualsiasi dei 4 fallisce.

Test Structure:

tests/
  default.nix - Test funzioni lib
    libTests/
      testHardwareDetect
      testSpringFramework
    moduleTests/
      testCoreModules
      testSecurityModules
  shell.nix - Ambiente linting

Assertions nei Moduli:

Ogni modulo che definisce opzioni DEVE avere una assertions che verifica:
assertions = [{ assertion = condizione; message = "Errore: spiegazione del problema"; }];


10. FLOW OPERATIVO AGENTE

Flow Chart:

USER RICHIEDE MODIFICA
  |
  v
CERCA IN src/modules/ il modulo pertinente
  | Se non esiste: crea nuova categoria, crea default.nix, crea file.nix
  |
  v
MODIFICA options/config
  |
  v
SHELL SCRIPTS? -> SI -> scripts/ (mai inline)
  | NO
  v
CONFIG FILES? -> SI -> config/ (mai inline)
  | NO
  v
HARDCODING? -> SI -> options + mkDefault + mkIf
  | NO
  v
COMMENTI nei .nix? -> SI -> RIMUOVI (vanno in AGENTS.md)
  | NO
  v
statix + deadnix + nixpkgs-fmt
  |
  v
VERIFICA idempotenza
  |
  v
nixos-rebuild switch (opzionale)

Regole per l'Agente:

1. MAI scrivere commenti nei .nix
2. MAI scrivere script shell inline nei .nix
3. MAI hardcodare username, hostname, path
4. SEMPRE usare options + mkOption per parametri
5. SEMPRE usare mkIf per attivazione condizionale
6. SEMPRE usare mkDefault per default sovrascrivibili
7. Script shell -> scripts/
8. Config files -> config/
9. documentazione tecnica -> AGENTS.md
10. documentazione utente -> docs/
11. Dopo ogni modifica: statix + deadnix + nixpkgs-fmt
12. Ogni modifica deve essere IDEMPOTENTE


Appendice A: Template Nuovo Modulo

{ config, lib, pkgs, ... }:
with lib;
let cfg = config.bora.category.module; in {
  options.bora.category.module = {
    enable = mkEnableOption "descrizione modulo";
    option1 = mkOption { type = types.str; default = "valore"; };
  };
  config = mkIf cfg.enable { attr = mkDefault cfg.option1; };
};

Appendice B: Template Nuovo Host

meta.nix:
{
  system = "x86_64-linux";
  hardware = "desktop";
  profile = "minimal";
  hostname = "os";
  username = "user";
}

default.nix:
{ config, lib, pkgs, username, hostname, ... }: {
  networking.hostName = hostname;
  users.users.${username} = { isNormalUser = true; extraGroups = [ "wheel" ]; };
};

Appendice C: Template Script Shell

File scripts/categoria/nome.sh:
#!/usr/bin/env bash
set -euo pipefail
ARG1="${1:?ARG1 required}"
ARG2="${2:-default}"
main() { printf "Executing: %s %s\n" "${ARG1}" "${ARG2}"; }
main "$@"

Riferimento in Nix:
pkgs.writeShellScriptBin "nome-comando" (builtins.readFile ./scripts/categoria/nome.sh)


BORA NixOS - Regole AgentiChe v2.0.0 - Sprint: Fondazione
Copyright 2026 - Distribuito sotto licenza MIT
