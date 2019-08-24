import os
import subprocess

def setupCron():
  cron = os.getenv('__CRON')
  cron_file = open('/etc/cron.d/liara_cron', 'w+')

  if not cron:
    cron_file.close()
    return

  envs = cron.split('$__SEP') if cron else []

  cron_file.write('PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\n')

  for i in range(len(envs)):
    cron_file.write(envs[i] + '\n')

  cron_file.close()

def setupPostBuildCommands():
  postBuildCommands = os.getenv('__LARAVEL_POSTBUILDCOMMANDS')

  if not postBuildCommands:
    return

  commands = postBuildCommands.split('$__SEP') if postBuildCommands else []

  for i in range(len(commands)):
    print('> post-build: ' + commands[i])
    result = subprocess.run(commands[i], stdout=subprocess.PIPE, shell=True, universal_newlines=True)

    print(result.stdout)

    if result.returncode is not 0:
      print('> post-build: command `' + commands[i] + '` returned a non-zore code: ' + str(result.returncode))
      exit(1)

def createDotEnvFile():
  envs = os.environ
  envs_file = open('/var/www/html/.env', 'w+')

  skip = [
    'HOSTNAME',
    'PHPIZE_DEPS',
    'GPG_KEYS',
    'PHP_EXTRA_CONFIGURE_ARGS',
    'PHP_ASC_URL',
    'PHP_CFLAGS',
    'ROOT',
    'COMPOSER_ALLOW_SUPERUSER',
    '__LARAVEL_CONFIGCACHE',
    'PHP_EXTRA_BUILD_DEPS',
    'PWD',
    'HOME',
    'PHP_LDFLAGS',
    'PHP_INI_DIR',
    'PHP_URL',
    'APACHE_ENVVARS',
    'PHP_CPPFLAGS',
    '__LARAVEL_ROUTECACHE',
    '__CRON',
    'TERM',
    'PHP_VERSION',
    'SHLVL',
    'PHP_EXTENSIONS',
    '__VOLUME_PATH',
    'PHP_MD5',
    'PATH',
    'PHP_SHA256',
    '_',
    'APACHE_CONFDIR',
    '__LARAVEL_POSTBUILDCOMMANDS',
  ]

  for key,value in envs.items():
    if key in skip:
      continue

    envs_file.write(key + '="' + value.replace('"','\\"') + '"\n')

  envs_file.close()

createDotEnvFile()
setupCron()
setupPostBuildCommands()
