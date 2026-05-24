import 'package:dash_tools/tools/docker/docker_run_to_compose.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── Parser ────────────────────────────────────────────────────────────────

  group('parseDockerRun — basic', () {
    test('returns null service for empty input', () {
      final r = parseDockerRun('');
      expect(r.service, isNull);
      expect(r.error, isNull);
    });

    test('parses image-only command', () {
      final r = parseDockerRun('docker run nginx');
      expect(r.error, isNull);
      expect(r.service!.image, 'nginx');
    });

    test('parses image with tag', () {
      final r = parseDockerRun('docker run nginx:alpine');
      expect(r.service!.image, 'nginx:alpine');
    });

    test('parses image with registry prefix', () {
      final r = parseDockerRun('docker run ghcr.io/myorg/myapp:v1.2.3');
      expect(r.service!.image, 'ghcr.io/myorg/myapp:v1.2.3');
    });

    test('strips "docker container run" prefix', () {
      final r = parseDockerRun('docker container run nginx');
      expect(r.service!.image, 'nginx');
    });

    test('error when no image specified', () {
      final r = parseDockerRun('docker run --rm');
      expect(r.error, isNotNull);
      expect(r.service, isNull);
    });
  });

  group('parseDockerRun — flags', () {
    test('--name sets containerName', () {
      final r = parseDockerRun('docker run --name myapp nginx');
      expect(r.service!.containerName, 'myapp');
    });

    test('--name=value syntax', () {
      final r = parseDockerRun('docker run --name=myapp nginx');
      expect(r.service!.containerName, 'myapp');
    });

    test('-p sets ports', () {
      final r = parseDockerRun('docker run -p 8080:80 nginx');
      expect(r.service!.ports, ['8080:80']);
    });

    test('multiple -p flags', () {
      final r = parseDockerRun('docker run -p 80:80 -p 443:443 nginx');
      expect(r.service!.ports, ['80:80', '443:443']);
    });

    test('-e sets environment', () {
      final r = parseDockerRun('docker run -e NODE_ENV=production nginx');
      expect(r.service!.environment, ['NODE_ENV=production']);
    });

    test('--env sets environment', () {
      final r = parseDockerRun('docker run --env KEY=VALUE nginx');
      expect(r.service!.environment, ['KEY=VALUE']);
    });

    test('-v sets volumes', () {
      final r = parseDockerRun('docker run -v ./data:/app/data nginx');
      expect(r.service!.volumes, ['./data:/app/data']);
    });

    test('--restart sets restart policy', () {
      final r = parseDockerRun('docker run --restart unless-stopped nginx');
      expect(r.service!.restart, 'unless-stopped');
    });

    test('--network sets networks', () {
      final r = parseDockerRun('docker run --network mynet nginx');
      expect(r.service!.networks, ['mynet']);
    });

    test('-d flag is ignored (detach)', () {
      final r = parseDockerRun('docker run -d nginx');
      expect(r.service!.image, 'nginx');
    });

    test('-it flag sets tty and stdinOpen', () {
      final r = parseDockerRun('docker run -it nginx bash');
      expect(r.service!.tty, isTrue);
      expect(r.service!.stdinOpen, isTrue);
    });

    test('-ti flag same as -it', () {
      final r = parseDockerRun('docker run -ti nginx');
      expect(r.service!.tty, isTrue);
      expect(r.service!.stdinOpen, isTrue);
    });

    test('--privileged sets privileged', () {
      final r = parseDockerRun('docker run --privileged nginx');
      expect(r.service!.privileged, isTrue);
    });

    test('--read-only sets readOnly', () {
      final r = parseDockerRun('docker run --read-only nginx');
      expect(r.service!.readOnly, isTrue);
    });

    test('--user sets user', () {
      final r = parseDockerRun('docker run --user 1000:1000 nginx');
      expect(r.service!.user, '1000:1000');
    });

    test('--workdir sets workingDir', () {
      final r = parseDockerRun('docker run --workdir /app nginx');
      expect(r.service!.workingDir, '/app');
    });

    test('--entrypoint sets entrypoint', () {
      final r = parseDockerRun('docker run --entrypoint /bin/sh nginx');
      expect(r.service!.entrypoint, '/bin/sh');
    });

    test('--hostname sets hostname', () {
      final r = parseDockerRun('docker run --hostname myhost nginx');
      expect(r.service!.hostname, 'myhost');
    });

    test('--memory sets memLimit', () {
      final r = parseDockerRun('docker run --memory 512m nginx');
      expect(r.service!.memLimit, '512m');
    });

    test('--cpus sets cpus', () {
      final r = parseDockerRun('docker run --cpus 0.5 nginx');
      expect(r.service!.cpus, '0.5');
    });

    test('--label adds label', () {
      final r = parseDockerRun('docker run --label app=myapp nginx');
      expect(r.service!.labels, ['app=myapp']);
    });

    test('--cap-add adds capability', () {
      final r = parseDockerRun('docker run --cap-add NET_ADMIN nginx');
      expect(r.service!.capAdd, ['NET_ADMIN']);
    });

    test('--cap-drop drops capability', () {
      final r = parseDockerRun('docker run --cap-drop ALL nginx');
      expect(r.service!.capDrop, ['ALL']);
    });

    test('--env-file adds env file', () {
      final r = parseDockerRun('docker run --env-file .env nginx');
      expect(r.service!.envFiles, ['.env']);
    });

    test('command after image is captured', () {
      final r = parseDockerRun('docker run nginx echo hello world');
      expect(r.service!.command, 'echo hello world');
    });
  });

  group('parseDockerRun — tokenizer', () {
    test('handles line continuations with backslash', () {
      const cmd = 'docker run \\\n  --name myapp \\\n  nginx';
      final r = parseDockerRun(cmd);
      expect(r.service!.containerName, 'myapp');
      expect(r.service!.image, 'nginx');
    });

    test('handles double-quoted values with spaces', () {
      final r = parseDockerRun('docker run -e "MY_VAR=hello world" nginx');
      expect(r.service!.environment, ['MY_VAR=hello world']);
    });

    test('handles single-quoted values with spaces', () {
      final r = parseDockerRun("docker run -e 'MY_VAR=hello world' nginx");
      expect(r.service!.environment.first, 'MY_VAR=hello world');
    });

    test('unterminated quote returns error', () {
      final r = parseDockerRun('docker run -e "bad nginx');
      expect(r.error, isNotNull);
    });
  });

  // ── Converter ─────────────────────────────────────────────────────────────

  group('convertToCompose', () {
    test('minimal service has image', () {
      const svc = DockerService(image: 'nginx');
      final yaml = convertToCompose(svc);
      expect(yaml, contains('image: nginx'));
      expect(yaml, contains('services:'));
    });

    test('service name derived from image', () {
      const svc = DockerService(image: 'nginx:alpine');
      final yaml = convertToCompose(svc);
      expect(yaml, contains('  nginx:'));
    });

    test('service name uses containerName when set', () {
      const svc = DockerService(image: 'nginx', containerName: 'myapp');
      final yaml = convertToCompose(svc);
      expect(yaml, contains('  myapp:'));
      expect(yaml, contains('container_name: myapp'));
    });

    test('ports are double-quoted', () {
      const svc = DockerService(image: 'nginx', ports: ['80:80']);
      final yaml = convertToCompose(svc);
      expect(yaml, contains('"80:80"'));
    });

    test('environment list emitted', () {
      const svc = DockerService(image: 'node', environment: ['NODE_ENV=production']);
      final yaml = convertToCompose(svc);
      expect(yaml, contains('environment:'));
      expect(yaml, contains('NODE_ENV=production'));
    });

    test('volumes list emitted', () {
      const svc = DockerService(image: 'nginx', volumes: ['./data:/app/data']);
      final yaml = convertToCompose(svc);
      expect(yaml, contains('volumes:'));
      expect(yaml, contains('./data:/app/data'));
    });

    test('host network becomes network_mode', () {
      const svc = DockerService(image: 'nginx', networks: ['host']);
      final yaml = convertToCompose(svc);
      expect(yaml, contains('network_mode: host'));
      expect(yaml, isNot(contains('networks:')));
    });

    test('named network emitted plus top-level external section', () {
      const svc = DockerService(image: 'nginx', networks: ['mynet']);
      final yaml = convertToCompose(svc);
      expect(yaml, contains('networks:'));
      expect(yaml, contains('mynet:'));
      expect(yaml, contains('external: true'));
    });

    test('bridge network is silently dropped', () {
      const svc = DockerService(image: 'nginx', networks: ['bridge']);
      final yaml = convertToCompose(svc);
      expect(yaml, isNot(contains('network_mode:')));
      expect(yaml, isNot(contains('external:')));
    });

    test('boolean flags only appear when true', () {
      const svc = DockerService(image: 'nginx', tty: true, stdinOpen: true);
      final yaml = convertToCompose(svc);
      expect(yaml, contains('tty: true'));
      expect(yaml, contains('stdin_open: true'));
      expect(yaml, isNot(contains('privileged:')));
    });

    test('mem_limit and cpus emitted', () {
      const svc = DockerService(image: 'nginx', memLimit: '512m', cpus: '0.5');
      final yaml = convertToCompose(svc);
      expect(yaml, contains('mem_limit: 512m'));
      expect(yaml, contains('cpus: "0.5"'));
    });

    test('restart policy emitted', () {
      const svc = DockerService(image: 'nginx', restart: 'unless-stopped');
      final yaml = convertToCompose(svc);
      expect(yaml, contains('restart: unless-stopped'));
    });
  });

  group('round-trip', () {
    test('full command produces valid compose with all fields', () {
      const cmd = 'docker run -d '
          '--name myapp '
          '-p 8080:80 '
          '-e NODE_ENV=production '
          '-v ./data:/app/data '
          '--restart unless-stopped '
          '--memory 512m '
          '--cpus 0.5 '
          '--privileged '
          'nginx:alpine';
      final parsed = parseDockerRun(cmd);
      expect(parsed.error, isNull);
      final yaml = convertToCompose(parsed.service!);
      expect(yaml, contains('image: nginx:alpine'));
      expect(yaml, contains('container_name: myapp'));
      expect(yaml, contains('"8080:80"'));
      expect(yaml, contains('NODE_ENV=production'));
      expect(yaml, contains('./data:/app/data'));
      expect(yaml, contains('restart: unless-stopped'));
      expect(yaml, contains('mem_limit: 512m'));
      expect(yaml, contains('cpus: "0.5"'));
      expect(yaml, contains('privileged: true'));
    });
  });
}
