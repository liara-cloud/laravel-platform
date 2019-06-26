import os

cron = os.getenv('__CRON')
cron_file = open('/etc/cron.d/liara_cron', 'w+')

if not cron:
  cron_file.close()
  exit(0)

envs = cron.split('$__SEP') if cron else []

for i in range(len(envs)):
  interval = ' '.join(envs[i].split(' ')[:5])
  command = ' '.join(envs[i].split(' ')[5:])
  cron_file.write(interval + ' . /etc/load_envs.sh; ' + command + '\n')

cron_file.close()