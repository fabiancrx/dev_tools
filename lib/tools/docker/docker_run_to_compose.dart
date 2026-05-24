/// Pure logic for converting a `docker run` command to Docker Compose YAML.
///
/// No Flutter imports. Tested independently from the UI.

class DockerService {
  final String image;
  final String? containerName;
  final String? restart;
  final String? user;
  final String? workingDir;
  final String? entrypoint;
  final String? hostname;
  final String? memLimit;
  final String? cpus;
  final String? shmSize;
  final bool privileged;
  final bool readOnly;
  final bool tty;
  final bool stdinOpen;
  final List<String> ports;
  final List<String> environment;
  final List<String> volumes;
  final List<String> networks;
  final List<String> labels;
  final List<String> capAdd;
  final List<String> capDrop;
  final List<String> envFiles;
  final List<String> links;
  final List<String> dns;
  final List<String> dnsSearch;
  final List<String> extraHosts;
  final String? command;

  const DockerService({
    required this.image,
    this.containerName,
    this.restart,
    this.user,
    this.workingDir,
    this.entrypoint,
    this.hostname,
    this.memLimit,
    this.cpus,
    this.shmSize,
    this.privileged = false,
    this.readOnly = false,
    this.tty = false,
    this.stdinOpen = false,
    this.ports = const [],
    this.environment = const [],
    this.volumes = const [],
    this.networks = const [],
    this.labels = const [],
    this.capAdd = const [],
    this.capDrop = const [],
    this.envFiles = const [],
    this.links = const [],
    this.dns = const [],
    this.dnsSearch = const [],
    this.extraHosts = const [],
    this.command,
  });
}

typedef DockerParseResult = ({DockerService? service, String? error});

/// Parses a `docker run` command string into a [DockerService].
DockerParseResult parseDockerRun(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return (service: null, error: null);

  List<String> tokens;
  try {
    tokens = _tokenizeShell(trimmed);
  } on FormatException catch (e) {
    return (service: null, error: e.message);
  }

  if (tokens.isEmpty) return (service: null, error: null);

  var i = 0;
  // Strip leading "docker [container] run"
  if (i < tokens.length && tokens[i] == 'docker') i++;
  if (i < tokens.length && tokens[i] == 'container') i++;
  if (i < tokens.length && tokens[i] == 'run') i++;

  String? image;
  String? containerName;
  String? restart;
  String? user;
  String? workingDir;
  String? entrypoint;
  String? hostname;
  String? memLimit;
  String? cpus;
  String? shmSize;
  var privileged = false;
  var readOnly = false;
  var tty = false;
  var stdinOpen = false;
  final ports = <String>[];
  final envVars = <String>[];
  final volumes = <String>[];
  final networks = <String>[];
  final labels = <String>[];
  final capAdd = <String>[];
  final capDrop = <String>[];
  final envFiles = <String>[];
  final links = <String>[];
  final dns = <String>[];
  final dnsSearch = <String>[];
  final extraHosts = <String>[];
  final commandParts = <String>[];

  while (i < tokens.length) {
    if (image != null) {
      commandParts.add(tokens[i++]);
      continue;
    }

    final token = tokens[i];

    if (!token.startsWith('-')) {
      image = token;
      i++;
      continue;
    }

    if (token.startsWith('--')) {
      final eqIdx = token.indexOf('=', 2);
      final flag = eqIdx >= 0 ? token.substring(2, eqIdx) : token.substring(2);
      String? eqValue = eqIdx >= 0 ? token.substring(eqIdx + 1) : null;

      String? nextVal() {
        if (eqValue != null) return eqValue;
        if (i + 1 < tokens.length) return tokens[++i];
        return null;
      }

      switch (flag) {
        case 'name':
          containerName = nextVal();
        case 'publish' || 'expose':
          final v = nextVal();
          if (v != null) ports.add(v);
        case 'env':
          final v = nextVal();
          if (v != null) envVars.add(v);
        case 'env-file':
          final v = nextVal();
          if (v != null) envFiles.add(v);
        case 'volume' || 'mount':
          final v = nextVal();
          if (v != null) volumes.add(v);
        case 'network' || 'net' || 'network-alias':
          if (flag != 'network-alias') {
            final v = nextVal();
            if (v != null) networks.add(v);
          } else {
            nextVal(); // consume and discard
          }
        case 'restart':
          restart = nextVal();
        case 'user':
          user = nextVal();
        case 'workdir':
          workingDir = nextVal();
        case 'entrypoint':
          entrypoint = nextVal();
        case 'hostname':
          hostname = nextVal();
        case 'memory':
          memLimit = nextVal();
        case 'cpus':
          cpus = nextVal();
        case 'shm-size':
          shmSize = nextVal();
        case 'label':
          final v = nextVal();
          if (v != null) labels.add(v);
        case 'cap-add':
          final v = nextVal();
          if (v != null) capAdd.add(v);
        case 'cap-drop':
          final v = nextVal();
          if (v != null) capDrop.add(v);
        case 'link':
          final v = nextVal();
          if (v != null) links.add(v);
        case 'dns':
          final v = nextVal();
          if (v != null) dns.add(v);
        case 'dns-search':
          final v = nextVal();
          if (v != null) dnsSearch.add(v);
        case 'add-host':
          final v = nextVal();
          if (v != null) extraHosts.add(v);
        case 'privileged':
          privileged = true;
        case 'read-only':
          readOnly = true;
        case 'tty':
          tty = true;
        case 'interactive':
          stdinOpen = true;
        case 'detach' || 'rm' || 'no-healthcheck' || 'init' || 'pull':
          // silently ignored — not representable in compose
          if (eqValue == null && flag != 'detach' && flag != 'rm' &&
              flag != 'no-healthcheck' && flag != 'init' && i + 1 < tokens.length &&
              !tokens[i + 1].startsWith('-')) {
            // unknown value flag — consume value to stay aligned
            i++;
          }
        default:
          // Unknown long flag — consume its value token if it looks like one
          if (eqValue == null && i + 1 < tokens.length && !tokens[i + 1].startsWith('-')) {
            i++;
          }
      }
      i++;
      continue;
    }

    // Short flags, possibly combined: -d, -it, -p, etc.
    final chars = token.substring(1);
    for (var j = 0; j < chars.length; j++) {
      final c = chars[j];
      final isLast = j == chars.length - 1;
      switch (c) {
        case 'd':
          break; // detach — ignored
        case 'i':
          stdinOpen = true;
        case 't':
          tty = true;
        case 'p' when isLast:
          if (i + 1 < tokens.length) ports.add(tokens[++i]);
        case 'e' when isLast:
          if (i + 1 < tokens.length) envVars.add(tokens[++i]);
        case 'v' when isLast:
          if (i + 1 < tokens.length) volumes.add(tokens[++i]);
        case 'u' when isLast:
          if (i + 1 < tokens.length) user = tokens[++i];
        case 'w' when isLast:
          if (i + 1 < tokens.length) workingDir = tokens[++i];
        case 'm' when isLast:
          if (i + 1 < tokens.length) memLimit = tokens[++i];
        case 'l' when isLast:
          if (i + 1 < tokens.length) labels.add(tokens[++i]);
        case 'h' when isLast:
          if (i + 1 < tokens.length) hostname = tokens[++i];
      }
    }
    i++;
  }

  if (image == null) {
    return (service: null, error: 'No image name found in the command');
  }

  return (
    service: DockerService(
      image: image,
      containerName: containerName,
      restart: restart,
      user: user,
      workingDir: workingDir,
      entrypoint: entrypoint,
      hostname: hostname,
      memLimit: memLimit,
      cpus: cpus,
      shmSize: shmSize,
      privileged: privileged,
      readOnly: readOnly,
      tty: tty,
      stdinOpen: stdinOpen,
      ports: List.unmodifiable(ports),
      environment: List.unmodifiable(envVars),
      volumes: List.unmodifiable(volumes),
      networks: List.unmodifiable(networks),
      labels: List.unmodifiable(labels),
      capAdd: List.unmodifiable(capAdd),
      capDrop: List.unmodifiable(capDrop),
      envFiles: List.unmodifiable(envFiles),
      links: List.unmodifiable(links),
      dns: List.unmodifiable(dns),
      dnsSearch: List.unmodifiable(dnsSearch),
      extraHosts: List.unmodifiable(extraHosts),
      command: commandParts.isEmpty ? null : commandParts.join(' '),
    ),
    error: null,
  );
}

/// Converts a [DockerService] to a Docker Compose v3 YAML string.
String convertToCompose(DockerService svc) {
  final buf = StringBuffer();
  buf.writeln('services:');

  final serviceName = svc.containerName ?? _serviceNameFromImage(svc.image);
  buf.writeln('  $serviceName:');
  buf.writeln('    image: ${svc.image}');

  if (svc.containerName != null) {
    buf.writeln('    container_name: ${_scalar(svc.containerName!)}');
  }
  if (svc.hostname != null) {
    buf.writeln('    hostname: ${_scalar(svc.hostname!)}');
  }
  if (svc.restart != null) {
    buf.writeln('    restart: ${_scalar(svc.restart!)}');
  }

  if (svc.ports.isNotEmpty) {
    buf.writeln('    ports:');
    for (final p in svc.ports) {
      buf.writeln('      - "${p.replaceAll('"', '\\"')}"');
    }
  }

  if (svc.envFiles.isNotEmpty) {
    buf.writeln('    env_file:');
    for (final f in svc.envFiles) {
      buf.writeln('      - ${_scalar(f)}');
    }
  }

  if (svc.environment.isNotEmpty) {
    buf.writeln('    environment:');
    for (final e in svc.environment) {
      buf.writeln('      - ${_scalar(e)}');
    }
  }

  if (svc.volumes.isNotEmpty) {
    buf.writeln('    volumes:');
    for (final v in svc.volumes) {
      buf.writeln('      - ${_scalar(v)}');
    }
  }

  // Separate special network modes from user-defined networks
  String? networkMode;
  final userNetworks = <String>[];
  for (final n in svc.networks) {
    if (n == 'host' || n == 'none') {
      networkMode = n;
    } else if (n != 'bridge') {
      userNetworks.add(n);
    }
  }

  if (networkMode != null) {
    buf.writeln('    network_mode: $networkMode');
  } else if (userNetworks.isNotEmpty) {
    buf.writeln('    networks:');
    for (final n in userNetworks) {
      buf.writeln('      - $n');
    }
  }

  if (svc.labels.isNotEmpty) {
    buf.writeln('    labels:');
    for (final l in svc.labels) {
      buf.writeln('      - ${_scalar(l)}');
    }
  }

  if (svc.capAdd.isNotEmpty) {
    buf.writeln('    cap_add:');
    for (final c in svc.capAdd) {
      buf.writeln('      - $c');
    }
  }

  if (svc.capDrop.isNotEmpty) {
    buf.writeln('    cap_drop:');
    for (final c in svc.capDrop) {
      buf.writeln('      - $c');
    }
  }

  if (svc.dns.isNotEmpty) {
    buf.writeln('    dns:');
    for (final d in svc.dns) {
      buf.writeln('      - $d');
    }
  }

  if (svc.dnsSearch.isNotEmpty) {
    buf.writeln('    dns_search:');
    for (final d in svc.dnsSearch) {
      buf.writeln('      - $d');
    }
  }

  if (svc.extraHosts.isNotEmpty) {
    buf.writeln('    extra_hosts:');
    for (final h in svc.extraHosts) {
      buf.writeln('      - ${_scalar(h)}');
    }
  }

  if (svc.links.isNotEmpty) {
    buf.writeln('    links:');
    for (final l in svc.links) {
      buf.writeln('      - ${_scalar(l)}');
    }
  }

  if (svc.command != null) buf.writeln('    command: ${_scalar(svc.command!)}');
  if (svc.entrypoint != null) buf.writeln('    entrypoint: ${_scalar(svc.entrypoint!)}');
  if (svc.user != null) buf.writeln('    user: ${_scalar(svc.user!)}');
  if (svc.workingDir != null) buf.writeln('    working_dir: ${_scalar(svc.workingDir!)}');
  if (svc.memLimit != null) buf.writeln('    mem_limit: ${svc.memLimit}');
  if (svc.cpus != null) buf.writeln('    cpus: "${svc.cpus}"');
  if (svc.shmSize != null) buf.writeln('    shm_size: ${_scalar(svc.shmSize!)}');
  if (svc.privileged) buf.writeln('    privileged: true');
  if (svc.readOnly) buf.writeln('    read_only: true');
  if (svc.tty) buf.writeln('    tty: true');
  if (svc.stdinOpen) buf.writeln('    stdin_open: true');

  // Top-level networks block for user-defined networks
  if (userNetworks.isNotEmpty) {
    buf.writeln();
    buf.writeln('networks:');
    for (final n in userNetworks) {
      buf.writeln('  $n:');
      buf.writeln('    external: true');
    }
  }

  return buf.toString().trimRight();
}

String _serviceNameFromImage(String image) {
  final lastSegment = image.split('/').last;
  final name = lastSegment.split(':').first.replaceAll(RegExp(r'[^a-z0-9_-]'), '_').toLowerCase();
  return name.isEmpty ? 'app' : name;
}

String _scalar(String s) {
  if (s.isEmpty) return '""';
  final needsQuote = s == 'true' ||
      s == 'false' ||
      s == 'null' ||
      s == 'yes' ||
      s == 'no' ||
      s == 'on' ||
      s == 'off' ||
      RegExp(r'^\d+$').hasMatch(s) ||
      RegExp(r'^\d+\.\d+$').hasMatch(s) ||
      s.startsWith(RegExp(r'[-?:,\[\]{}\#&*!|>'"'"'"%@`]')) ||
      s.contains(': ') ||
      s.contains(' #') ||
      s.contains('\n');
  if (!needsQuote) return s;
  return '"${s.replaceAll('\\', '\\\\').replaceAll('"', '\\"')}"';
}

/// Minimal POSIX-like shell tokenizer supporting:
/// - single quotes (no escaping inside)
/// - double quotes (`\"`, `\\`, `\$`, `` \` `` processed)
/// - backslash escaping outside quotes
/// - line continuation (`\<newline>`)
List<String> _tokenizeShell(String input) {
  final src = input.replaceAll(RegExp(r'\\\s*\n\s*'), ' ');
  final tokens = <String>[];
  final cur = StringBuffer();
  var inSingle = false;
  var inDouble = false;
  var i = 0;

  while (i < src.length) {
    final ch = src[i];

    if (inSingle) {
      if (ch == "'") {
        inSingle = false;
      } else {
        cur.write(ch);
      }
      i++;
      continue;
    }

    if (inDouble) {
      if (ch == '"') {
        inDouble = false;
      } else if (ch == '\\' && i + 1 < src.length) {
        final next = src[i + 1];
        if (next == '"' || next == '\\' || next == r'$' || next == '`') {
          cur.write(next);
          i += 2;
        } else if (next == '\n') {
          i += 2; // line continuation inside double quotes
        } else {
          cur.write(ch);
          i++;
        }
        continue;
      } else {
        cur.write(ch);
      }
      i++;
      continue;
    }

    // Unquoted
    if (ch == "'") {
      inSingle = true;
    } else if (ch == '"') {
      inDouble = true;
    } else if (ch == '\\' && i + 1 < src.length) {
      cur.write(src[i + 1]);
      i += 2;
      continue;
    } else if (ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r') {
      if (cur.isNotEmpty) {
        tokens.add(cur.toString());
        cur.clear();
      }
    } else {
      cur.write(ch);
    }
    i++;
  }

  if (inSingle || inDouble) throw const FormatException('Unterminated quote in command');
  if (cur.isNotEmpty) tokens.add(cur.toString());
  return tokens;
}

const dockerRunSample = '''
docker run -d \\
  --name myapp \\
  -p 8080:80 \\
  -e NODE_ENV=production \\
  -e DB_PASSWORD=secret \\
  -v ./data:/app/data \\
  --restart unless-stopped \\
  --memory 512m \\
  nginx:alpine
''';
