BORA NixOS AgentiC Rules and Sprint Definitions
Strict Hard Zero Hardcoding Zero Comments Zero Inline Shell
Version 2.0.0 Sprint Fondazione

INDICE

1. Architettura del Repository
2. Regole Assolute
3. Parametrizzazione Zero Hardcoding
4. Sprint Definitions
5. Spring Framework Specifica Tecnica
6. Resource Management e Circuit Breaker
7. Security Baseline
8. Idempotenza e Atomicita
9. Testing e Quality Gates
10. Flow Operativo Agente

1. ARCHITETTURA DEL REPOSITORY

L albero delle directory del repository segue questa struttura. La radice contiene flake.nix che e il punto di ingresso stateless e puro. configuration.nix e il module loader che esegue auto scan dinamico. AGENTS.md e questo file con le regole agentiche e le sprint definitions. lib contiene le Nix libraries con funzioni pure esportate da default.nix hardware.nix per auto detection di CPU GPU e platform e spring.nix per il DI IoC Container con Circuit Breaker. src contiene il NixOS source con hosts per le host definitions per macchina profiles per le profile definitions per use case modules organizzati per categoria guests per le MicroVM guest definitions config per i runtime config files scripts per gli shell scripts assets per gli static assets secrets per i secret crittografati con SOPS e age tests per i Nix tests e docs per la documentazione.

I principi architetturali sono i seguenti. Single responsibility significa che ogni file Nix ha un solo scopo. No side effects significa che le funzioni in lib sono pure senza effetti collaterali. Auto discovery significa che configuration.nix scansiona src/modules senza import manuali. Parametrizzazione significa tutto via options con mkOption senza hardcoded. External shell significa script shell in scripts riferiti via builtins.readFile. External config significa file config in config riferiti via path relativo.

2. REGOLE ASSOLUTE

Regola 1 e Zero Comments nei file Nix. Vietato il commento inline con hash. Vietato il commento a blocchi con slash asterisco. Vietato il commento multilinea. La documentazione va in AGENTS.md per la documentazione tecnica e in docs per la documentazione utente. Solo AGENTS.md e i file in docs possono contenere testo.

Regola 2 e Zero Shell Inline in Nix. Vietato scrivere script shell dentro stringhe Nix tra apici. Vietato usare pkgs.writeShellScript con stringhe inline. Vietato utilizzare espressioni shell dentro stringhe Nix. Ogni script shell deve essere in scripts come file separato. Il riferimento corretto e pkgs.writeShellScriptBin name con builtins.readFile che legge il percorso dello script.

Regola 3 e Zero Hardcoding. Vietato hardcodare username come alessio o kairosci. Vietato hardcodare hostname come bora o os. Vietato hardcodare path IP porte o UUID. Vietato hardcodare CPU GPU o RAM config. L username deve venire da meta.nix o option. L hostname deve venire da meta.nix o option. L hardware deve usare opzioni con lib.mkDefault. L attivazione deve usare lib.mkIf. Nessun valore letterale ogni valore deve essere una variabile.

Regola 4 e Atomicita Strutturale. Ogni modifica deve produrre un new generation atomico. Vietati workaround fallback e placeholders. Vietati TODO FIXME e HACK. Vietati commenti per disabilitare codice. Per disabilitare un modulo si usa mkIf false. Una funzione non implementata non deve esistere.

Regola 5 e Modularita Dinamica. configuration.nix scansiona src/modules automaticamente. Ogni categoria corrisponde a src/modules/categoria. Ogni categoria ha default.nix che importa i sottomoduli. I moduli si abilitano via mkIf cfg.enable. I profili attivano combinazioni di moduli. Per creare un nuovo modulo si crea src/modules/categoria/nome.nix si aggiorna src/modules/categoria/default.nix si definiscono options con enable e parametri e si usa mkIf cfg.enable per la config.

3. PARAMETRIZZAZIONE ZERO HARDCODING

Tutti i parametri host specific sono dichiarati in src/hosts/hostname/meta.nix e iniettati via specialArgs. Il template generico di meta.nix contiene system come architettura di sistema hardware come tipo di hardware profile come profilo d uso hostname come nome host e username come nome utente. Le regole di sostituzione prevedono che username nei users.users diventi il valore di username username nei path home diventi home con username hostname in networking.hostName diventi il valore di hostname hostname in spring.application.name diventi il valore di hostname persist in environment.persistence legga da option e i path assoluti per config e scripts siano path relativi.

4. SPRINT DEFINITIONS

Sprint 1 e Fondazione con lo scopo di creare la struttura base del sistema funzionante. Include flake.nix come entry point puro con inputs dichiarativi configuration.nix come module loader auto scan lib/default.nix che esporta tutte le librerie lib/hardware.nix come database CPU GPU e Platform src/modules/core per Boot Nix Locale e Sysctl src/hosts/hostname con meta default e hardware e AGENTS.md.

Sprint 2 e Filesystem e Immutabilita con lo scopo di implementare ZFS Impermanence e Disko. Include il modulo zfs per pool ARC e snapshot il modulo impermanence per persist config desktop per file config esterni sanoid per snapshot retention automatica e disko per partizionamento dichiarativo.

Sprint 3 e Sicurezza con lo scopo di implementare hardening estremo firewall e SSH. Include il modulo firewall con nftables default drop la configurazione nftables esterna il modulo hardening per kernel e AppArmor il modulo ssh con solo chiavi solo LAN e audit logging con fail2ban.

Sprint 4 e Hardware Detection con lo scopo di auto configurare CPU GPU e Platform. Include il modulo cpu per Intel AMD e ARM il modulo gpu per NVIDIA AMD e Intel il modulo platform per Desktop Laptop e Server e lib/hardware.nix come database ottimizzazioni per vendor.

Sprint 5 e Desktop e Bora Layout con lo scopo di realizzare KDE Plasma 6 minimale con layout Bora originale. Include il modulo kde-minimal per Plasma 6 essenziale il modulo maclike per il tema Bora il modulo pipewire per audio gli script maclike per init e finalize shell e i file config desktop per plasma-appletsrc kdeglobals e kwinrc.

Sprint 6 e Container Engine con lo scopo di realizzare il container engine con isolamento hardware level. Include il modulo microvm-host per host e bridge il modulo orchestrator per pool manager il guest sandbox come template generico la configurazione containers per bridge e networking e SocketVM per app desktop con forwarding X11 e Wayland.

Sprint 7 e Spring Framework con lo scopo di implementare Dependency Injection e Circuit Breaker. Include lib/spring.nix per bean definitions topological sort mkSystemdService con resource limits circuit breaker con failure success e stato circular dependency detection e gli script spring per cgroup-init circuit-breaker e health. Include anche l aggiornamento dell orchestrator per usare Spring beans.

Sprint 8 e Instance Pool Orchestrator con lo scopo di realizzare il pool di istanze isolate per qualsiasi applicazione. Include il modulo instance-pool con opzioni pool la guest definition per applicazione la pool configuration gli script pool per pool-manager spawn list e stats cgroup v2 per isolamento risorse per istanza e reverse proxy Caddy per routing alle istanze.

Sprint 9 e Testing e Documentazione con lo scopo di implementare test Nix puri e documentazione completa. Include tests/default.nix per test librerie pure tests/shell.nix per ambiente linting con statix e deadnix docs/BORA-WP.md come manuale utente in formato testo AGENTS.md per regole agentiche sempre aggiornate e ISO generation per deploy immediato.

Il flusso degli sprint procede da Sprint 1 a Sprint 2 a Sprint 3 a Sprint 4 da cui si dirama a Sprint 5 che prosegue a Sprint 6 che porta a Sprint 7 e Sprint 8 e infine Sprint 9. Ogni sprint produce una generazione NixOS funzionante senza dipendenze non soddisfatte.

La cronologia degli sprint registra tutti i completamenti. Tutti gli sprint dal numero 1 al numero 9 sono completati. Il sistema e pronto per build e deploy.

5. SPRING FRAMEWORK SPECIFICA TECNICA

La definizione di un bean avviene tramite bora.spring.beans.nome con attributi enable per abilitare class come tipo di servizio deps come lista di bean da cui dipende resources con cpu memory memoryMax pids ioRbps ioWbps e numa healthcheck come comando per verificare lo stato dependsOn per dipendenze systemd after per ordinamento systemd e restartPolicy per policy di riavvio.

La macchina a stati del Circuit Breaker ha tre stati. CLOSED e funzionamento normale dove le richieste passano e i failure incrementano un contatore. OPEN e circuito aperto dove le richieste sono bloccate e un timer di timeout viene avviato. HALF-OPEN e test di recupero dove richieste limitate sono permesse. Le transizioni prevedono che CLOSED passi a OPEN quando i failure raggiungono la threshold che di default e 5. OPEN passa a HALF-OPEN dopo il timeout che di default e 30 secondi. HALF-OPEN passa a CLOSED quando i success raggiungono la threshold che di default e 2. HALF-OPEN passa a OPEN quando si verifica un failure in half-open.

Il topological sort risolve le dipendenze tra bean a build time. Se esiste un ciclo il build fallisce con un messaggio di errore che indica la presenza di una circular dependency nei bean specificati.

6. RESOURCE MANAGEMENT E CIRCUIT BREAKER

La gerarchia cgroup v2 e organizzata sotto sys fs cgroup con il nome host che contiene bean-database bean-redis e bean-webapp con cpu.max memory.max pids.max e io.max e OOM policy kill. La sezione bora contiene pool per le istanze MicroVM con instance-001 e instance-002 con cpu.max al 50 percento e memory.max a 256 MB.

La protezione OOM prevede OOMPolicy kill per tutti i servizi Spring. MemoryHigh e il soft limit per throttling prima di OOM. MemoryMax e l hard limit per OOM kill se superato. DefaultMemoryAccounting e yes globalmente. Il flusso di health check esegue il comando healthcheck. Se il risultato e success chiama circuit_success. Se il risultato e failure chiama circuit_trip. In stato CLOSED incrementa il contatore e se supera la threshold passa a OPEN. In stato OPEN attende il timeout poi passa a HALF-OPEN. In stato HALF-OPEN se il numero di tentativi e inferiore al massimo riprova altrimenti passa a CLOSED. Se il circuito e OPEN il servizio non parte ed esce con codice 1.

7. SECURITY BASELINE

I parametri kernel sysctl includono kernel.kptr_restrict impostato a 2 kernel.dmesg_restrict a 1 kernel.perf_event_paranoid a 3 kernel.yama.ptrace_scope a 2 kernel.randomize_va_space a 2 kernel.unprivileged_bpf_disabled a 1 net.core.bpf_jit_enable a 0 kernel.kexec_load_disabled a 1 e kernel.sysrq a 0.

Il firewall nftables definisce chain input con policy DROP che accetta connessioni stabilite e correlate traffico su interfaccia loopback ICMP con rate limit di 10 al secondo e TCP porta 22 da indirizzi LAN e registra e droppa tutto il resto. chain forward con policy DROP accetta connessioni stabilite e correlate e traffico dall interfaccia microvm. chain output con policy ACCEPT.

L hardening SSH prevede PermitRootLogin no PasswordAuthentication no PubkeyAuthentication yes MaxAuthTries 3 MaxSessions 4 AllowTcpForwarding no AllowAgentForwarding no cifrari ChaCha20-Poly1305 e AES-256-GCM e MACs HMAC-SHA2-512-ETM e HMAC-SHA2-256-ETM. AppArmor e enforced con cache attiva profili da apparmor-profiles e lockdown impostato a confidentiality.

8. IDEMPOTENZA E ATOMICITA

Le regole di idempotenza richiedono che nixos-rebuild switch sia idempotente eseguendolo due volte di seguito deve produrre lo stesso risultato. Non ci devono essere side effects fuori dal nix store. La directory etc viene rigenerata a ogni build. Lo stato utente risiede solo in persist e home. Il root filesystem e effimero tramite impermanence.

Per quanto riguarda l atomicita ogni nixos-rebuild produce una new generation. La generazione precedente rimane intatta nel boot menu. Il rollback si esegue con nixos-rebuild switch rollback. ZFS esegue snapshot automatico pre rebuild e snapshot post rebuild via sanoid. Workaround tentativi hack e placeholders hanno tolleranza zero.

9. TESTING E QUALITY GATES

I quality gates obbligatori prima di ogni commit includono statix check src per linting Nix deadnix src per dead code detection nixpkgs-fmt check src per formattazione e nix-instantiate eval tests per valutazione test. Il commit deve fallire se uno qualsiasi dei quattro fallisce.

La struttura dei test prevede tests/default.nix per test funzioni lib con testHardwareDetect testSpringFramework testCoreModules e testSecurityModules e tests/shell.nix per ambiente linting. Ogni modulo che definisce opzioni deve avere assertions che verificano condizioni con messaggio di errore.

10. FLOW OPERATIVO AGENTE

Quando l utente richiede una modifica l agente cerca in src/modules il modulo pertinente. Se non esiste crea una nuova categoria crea default.nix e crea il file del modulo. Poi modifica options e config. Se sono necessari script shell vanno in scripts mai inline. Se sono necessari file config vanno in config mai inline. Se c e hardcoding va sostituito con options mkDefault e mkIf. Se ci sono commenti nei file Nix vanno rimossi e messi in AGENTS.md. Poi esegue statix deadnix e nixpkgs-fmt. Verifica l idempotenza e infine esegue opzionalmente nixos-rebuild switch.

Le regole per l agente sono le seguenti. Mai scrivere commenti nei file Nix. Mai scrivere script shell inline nei file Nix. Mai hardcodare username hostname o path. Sempre usare options con mkOption per parametri. Sempre usare mkIf per attivazione condizionale. Sempre usare mkDefault per default sovrascrivibili. Script shell in scripts. Config files in config. Documentazione tecnica in AGENTS.md. Documentazione utente in docs. Dopo ogni modifica eseguire statix deadnix e nixpkgs-fmt. Ogni modifica deve essere idempotente.

Il template per un nuovo modulo prevede la definizione di config lib pkgs con l utilizzo di let cfg config.bora.category.module per accedere alle opzioni. options.bora.category.module deve contenere enable come mkEnableOption e option1 come mkOption con type e default. config deve essere wrappato in mkIf cfg.enable con attr impostato a mkDefault cfg.option1.

Il template per un nuovo host prevede un file meta.nix con system hardware profile hostname e username. Il file default.nix riceve config lib pkgs username e hostname e configura networking.hostName con hostname e users.users con username come isNormalUser true e extraGroups con wheel.

Il template per script shell prevede il file in scripts/categoria/nome.sh con shebang bash set euo pipefail parametri con default e funzione main che esegue la logica. Il riferimento in Nix usa pkgs.writeShellScriptBin con builtins.readFile per leggere il percorso dello script.

BORA NixOS Regole AgentiChe v2.0.0 Sprint Fondazione
Copyright 2026 Distribuito sotto licenza MIT
