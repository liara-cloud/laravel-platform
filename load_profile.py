import os
import json
import subprocess

def setupCron():
  cron = os.getenv('__CRON') or '[]'
  crontab = open('/run/liara/crontab', 'w+')

  try:
    envs = json.loads(cron)
  except ValueError:
    envs = cron.split('$__SEP')

  for i in range(len(envs)):
    crontab.write(envs[i] + '\n')

  crontab.close()

def runPostBuildCommands():
  postBuildCommands = os.getenv('__LARAVEL_POSTBUILDCOMMANDS') or '[]'

  try:
    commands = json.loads(postBuildCommands)
  except ValueError:
    commands = postBuildCommands.split('$__SEP')

  for i in range(len(commands)):
    print('> post-build: ' + commands[i])
    result = subprocess.run(commands[i], stdout=subprocess.PIPE, shell=True, universal_newlines=True)

    print(result.stdout)

    if result.returncode is not 0:
      print('> post-build: command `' + commands[i] + '` returned a non-zore code: ' + str(result.returncode))
      exit(1)

def chownDiskMountpoints():
  disks = json.loads(os.getenv('__DISKS') or '[]')
  for disk in disks:
    # FIXME: Remember that an attacker can interpolate disk['mountTo'] and run any command he wants.
    # In our new version of this platform, we have to fix this by validation any input given by user.
    # Bacuase we don't want to allow them to have root access in the container.
    result = subprocess.run('chown -R www-data:www-data ' + disk['mountTo'], stdout=subprocess.PIPE, shell=True, universal_newlines=True)
    if result.returncode is not 0:
      print(result.stdout)
      print('> `chown www-data:www-data ' + disk['mountTo'] + '` command returned a non-zore code: ' + str(result.returncode))
      exit(1)

chownDiskMountpoints()
setupCron()
runPostBuildCommands()
