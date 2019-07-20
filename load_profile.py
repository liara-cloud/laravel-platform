import os
import subprocess

def setupCron():
  cron = os.getenv('__CRON')
  cron_file = open('/etc/cron.d/liara_cron', 'w+')

  if not cron:
    cron_file.close()
    return

  envs = cron.split('$__SEP') if cron else []

  for i in range(len(envs)):
    interval = ' '.join(envs[i].split(' ')[:5])
    command = ' '.join(envs[i].split(' ')[5:])
    cron_file.write(interval + ' . /etc/load_envs.sh; ' + command + '\n')

  cron_file.close()

def setupPostBuildCommands():
  postBuildCommands = os.getenv('__LARAVEL_POSTBUILDCOMMANDS')

  if not postBuildCommands:
    return

  commands = postBuildCommands.split('$__SEP') if postBuildCommands else []

  for i in range(len(commands)):
    print('> post-build: ' + commands[i])
    result = subprocess.run(commands[i].split(' '), stdout=subprocess.PIPE, shell=True, universal_newlines=True)

    print(result.stdout)

    if result.returncode is not 0:
      print('> post-build: command `' + commands[i] + '` returned a non-zore code: ' + str(result.returncode))
      exit(1)

setupCron()
setupPostBuildCommands()