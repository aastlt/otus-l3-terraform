# Ansible Bootstrap Project

Проект для автоматизированной начальной настройки серверов с базовой конфигурацией безопасности и системных компонентов.

## Описание

Bootstrap проект выполняет комплексную первоначальную настройку серверов, включая:
- Обновление системных пакетов и настройка автообновлений
- Базовая системная конфигурация (timezone, sysctl, locales, NTP)
- Создание пользователей и настройка SSH доступа
- Конфигурация файрвола iptables с защитой от сканирования
- Настройки безопасности и мониторинга

## Структура проекта

```
bootstrap/
├── bootstrap.yml        # Основной плейбук
├── ansible.cfg          # Конфигурация Ansible
├── .ansible-lint        # Правила линтера
├── inventory/
│   └── hosts            # Инвентарь хостов
├── group_vars/
│   └── all.yml          # Глобальные переменные
├── host_vars/
│   └── *.yml            # Переменные для конкретных хостов
└── roles/
    ├── apt/             # Управление пакетами APT
    ├── common/          # Базовая системная конфигурация
    ├── users/           # Создание пользователей
    ├── ssh/             # Настройка SSH сервера
    └── iptables/        # Конфигурация файрвола
```

## Роли

### apt
- Обновление списка пакетов и системы
- Установка базовых системных пакетов
- Настройка автоматических обновлений безопасности
- Конфигурация источников пакетов

### common
- Настройка часового пояса и NTP синхронизации
- Конфигурация системных параметров ядра (sysctl)
- Управление локалями системы
- Настройка sudo и системных пользователей
- Конфигурация hostname и DNS резолвинга

### users
- Создание системных и административных пользователей
- Настройка sudo привилегий и групп
- Управление SSH ключами пользователей
- Конфигурация домашних директорий

### ssh
- Конфигурация SSH сервера с повышенной безопасностью
- Изменение стандартного порта SSH
- Отключение небезопасных методов аутентификации
- Настройка ограничений доступа

### iptables
- Настройка комплексного файрвола с защитой от атак
- Защита от сканирования портов и DDoS
- Управление правилами для входящих/исходящих соединений
- Поддержка различных дистрибутивов Linux

## Переменные

### Глобальные (group_vars/all.yml)
```yaml
# SSH конфигурация
ssh_port: 50022                    # Порт SSH сервера
ansible_port: 22                   # Порт для подключения Ansible

# Системные настройки
tz: Europe/Moscow                  # Часовой пояс

# Параметры ядра (sysctl)
sysctl_default:
  net.ipv6.conf.all.disable_ipv6:
    value: 1
    state: present
  net.core.somaxconn:
    value: 4096
    state: present

# Локали
common_locales_present_list:
  - lang: en_US.UTF-8
  - lang: ru_RU.UTF-8
```

### Переменные ролей

**apt роль:**
- `apt_packages` - список устанавливаемых пакетов
- `apt_unattended_upgrades` - настройки автообновлений

**common роль:**
- `tz` - часовой пояс системы
- `sysctl_default/custom` - параметры ядра
- `common_locales_*` - управление локалями
- `ntp_server` - NTP сервер для синхронизации

**users роль:**
- `users_list` - список создаваемых пользователей
- `users_sudo_group` - группа sudo пользователей

**ssh роль:**
- `ssh_port` - порт SSH сервера
- `ssh_permit_root_login` - разрешение root доступа
- `ssh_password_authentication` - аутентификация по паролю

**iptables роль:**
- `iptables_rules_in/out` - правила файрвола
- `iptables_rate_limiting` - ограничение скорости
- `iptables_logging` - логирование событий

## Конфигурация Ansible

**ansible.cfg** содержит оптимизированные настройки:
```ini
[defaults]
remote_user = debian              # Пользователь по умолчанию
inventory = inventory/hosts       # Путь к инвентарю
interpreter_python = /usr/bin/python3
host_key_checking = False
forks = 20                        # Параллельные подключения

[ssh_connection]
pipelining = True                 # Ускорение SSH
ssh_args = -o ControlMaster=auto -o ControlPersist=15m

[privilege_escalation]
become = True
become_method = sudo
```

## Быстрый старт

### 1. Подготовка окружения

```bash
# Клонируйте проект
git clone https://github.com/aastlt/ansible-bootstrap
cd ansible-bootstrap

# Установите зависимости Ansible
ansible-galaxy collection install community.general
ansible-galaxy collection install ansible.posix

# Настройте inventory
cp inventory/hosts.example inventory/hosts
vim inventory/hosts
```

### 2. Конфигурация

**inventory/hosts** - добавьте ваши серверы:
```ini
[bootstrap]
server1 ansible_host=192.168.1.10
server2 ansible_host=192.168.1.11

[bootstrap:vars]
ansible_user=debian
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

**group_vars/all.yml** - настройте основные параметры:
```yaml
ssh_port: 50022
ansible_port: 22  # Изменить на 50022 после первого запуска
tz: Europe/Moscow
```

### 3. Выполнение

```bash
# Проверка подключения
ansible all -m ping

# Проверка синтаксиса
ansible-playbook --syntax-check bootstrap.yml

# Тестовый запуск (dry-run)
ansible-playbook bootstrap.yml --check --diff

# Выполнение на тестовом хосте
ansible-playbook -l 'server1' bootstrap.yml --diff

# Полное выполнение на всех хостах
ansible-playbook bootstrap.yml --diff

# После изменения SSH порта обновите ansible_port
# в group_vars/all.yml или inventory/hosts
```

### 4. Поэтапное выполнение

```bash
# Только обновление пакетов
ansible-playbook bootstrap.yml --tags apt

# Только настройка SSH
ansible-playbook bootstrap.yml --tags ssh

# Пропустить настройку файрвола
ansible-playbook bootstrap.yml --skip-tags iptables

# Выполнить только на определенной группе
ansible-playbook -l 'web_servers' bootstrap.yml
```

## Примеры использования

### Базовая конфигурация
```yaml
# group_vars/all.yml
ssh_port: 50022
ansible_port: 22
tz: Europe/Moscow

sysctl_default:
  net.ipv6.conf.all.disable_ipv6:
    value: 1
    state: present
```

### Создание пользователей
```yaml
# group_vars/all.yml или host_vars/hostname.yml
users_list:
  - name: admin
    groups: [sudo, adm]
    ssh_key: "ssh-rsa AAAAB3NzaC1yc2E..."
    shell: /bin/bash
  - name: deploy
    groups: [www-data]
    ssh_key: "ssh-ed25519 AAAAC3NzaC1lZDI1..."
```

### Настройка файрвола
```yaml
# group_vars/all.yml
iptables_rules_in:
  - protocol: tcp
    dport: 80
    comment: "HTTP"
  - protocol: tcp
    dport: 443
    comment: "HTTPS"
  - protocol: tcp
    dport: "{{ ssh_port }}"
    comment: "SSH"
```

## Архитектура плейбука

**bootstrap.yml** выполняет роли в следующем порядке:
1. **Сбор фактов** - кэширование информации о системе
2. **apt** - обновление пакетов и настройка репозиториев
3. **common** - базовая системная конфигурация
4. **users** - создание пользователей и настройка доступа
5. **ssh** - конфигурация SSH сервера
6. **iptables** - настройка файрвола (последним для безопасности)

## Особенности реализации

### Производительность
- **Кэширование фактов** в `/tmp/ansible_facts/bootstrap`
- **Pipelining SSH** для ускорения выполнения
- **Параллельное выполнение** на 20 хостах одновременно
- **Smart gathering** - сбор только измененных фактов

### Безопасность
- **Изменение SSH порта** для защиты от сканирования
- **Отключение root доступа** по SSH
- **Комплексный файрвол** с защитой от DDoS
- **Автоматические обновления** безопасности

### Мониторинг
- **Профилирование задач** с помощью callback плагинов
- **Детальное логирование** выполнения ролей
- **Отображение пропущенных** и успешных задач

## Требования

### Системные требования
- **Ansible** >= 2.9
- **Python** >= 3.6 на управляющем хосте
- **Python3** на целевых хостах

### Сетевые требования
- SSH доступ к целевым хостам (порт 22 изначально)
- Sudo права на целевых хостах
- Доступ к интернету для загрузки пакетов

### Ansible Collections
```bash
ansible-galaxy collection install community.general
ansible-galaxy collection install ansible.posix
```

## Устранение неполадок

### Проблемы с SSH подключением

**Потеря SSH соединения после изменения порта:**
```bash
# Подключение через консоль сервера или KVM
ssh -p 22 user@host  # если порт еще не изменился

# Откат конфигурации SSH
sudo systemctl restart ssh
sudo systemctl status ssh

# Проверка портов
sudo netstat -tlnp | grep ssh
```

**Обновление Ansible конфигурации:**
```bash
# Обновите ansible_port в inventory или group_vars
vim group_vars/all.yml
# ansible_port: 50022

# Или временно укажите порт в команде
ansible-playbook -e ansible_port=50022 bootstrap.yml
```

### Проблемы с файрволом

**Блокировка доступа iptables:**
```bash
# Экстренное отключение через консоль
sudo iptables -F                    # Очистить все правила
sudo iptables -P INPUT ACCEPT       # Разрешить входящие
sudo iptables -P OUTPUT ACCEPT      # Разрешить исходящие

# Перезапуск службы iptables
sudo systemctl restart iptables-persistent
```

**Восстановление правил:**
```bash
# Повторный запуск только роли iptables
ansible-playbook bootstrap.yml --tags iptables -e iptables_flush=true
```

### Отладка выполнения

**Детальная диагностика:**
```bash
# Максимальный уровень отладки
ansible-playbook -vvv bootstrap.yml

# Проверка подключения к хостам
ansible all -m ping -vv

# Проверка конкретной роли
ansible-playbook bootstrap.yml --tags common --check -v

# Сбор фактов о системе
ansible all -m setup | grep ansible_distribution
```

**Проверка синтаксиса и линтинг:**
```bash
# Проверка синтаксиса плейбука
ansible-playbook --syntax-check bootstrap.yml

# Линтинг с помощью ansible-lint
ansible-lint bootstrap.yml

# Проверка конкретной роли
ansible-lint roles/ssh/
```

### Частые проблемы

**Ошибка "Permission denied (publickey)":**
- Проверьте SSH ключи: `ssh-add -l`
- Убедитесь в правильности пути к ключу в inventory
- Проверьте права на ключ: `chmod 600 ~/.ssh/id_rsa`

**Ошибка "sudo: a password is required":**
- Настройте NOPASSWD для пользователя в sudoers
- Или используйте `--ask-become-pass` при запуске

**Таймаут подключения:**
- Увеличьте timeout в ansible.cfg
- Проверьте сетевую доступность хостов
- Убедитесь в правильности IP адресов в inventory

## Безопасность

⚠️ **Важные моменты:**

1. **SSH порт**: После изменения SSH порта обновите `ansible_port` в конфигурации
2. **Файрвол**: Убедитесь, что SSH порт открыт в iptables перед применением правил
3. **Пользователи**: Создайте пользователя с sudo правами перед отключением root доступа
4. **Тестирование**: Всегда тестируйте на тестовом сервере перед применением в продакшене

## Рекомендации по использованию

### Тестирование
1. **Всегда тестируйте** на изолированном сервере перед продакшеном
2. **Используйте --check** для предварительной проверки изменений
3. **Создавайте снапшоты** виртуальных машин перед выполнением

### Безопасность
1. **Измените SSH порт** сразу после первого запуска
2. **Создайте пользователя** с sudo правами перед отключением root
3. **Настройте файрвол** с учетом используемых сервисов
4. **Регулярно обновляйте** SSH ключи и пароли

### Мониторинг
1. **Проверяйте логи** выполнения плейбуков
2. **Мониторьте доступность** серверов после изменений
3. **Ведите документацию** внесенных изменений

## Расширение функциональности

### Добавление новых ролей
```bash
# Создание новой роли
ansible-galaxy init roles/monitoring

# Добавление в плейбук
vim bootstrap.yml
# - role: monitoring
```

### Кастомизация под проект
- Создайте отдельные inventory для разных окружений
- Используйте host_vars для специфичных настроек хостов
- Добавьте теги для селективного выполнения задач

## Лицензия

MIT License

## Автор

aastlt

## Поддержка

Для вопросов и предложений создавайте issues в репозитории проекта.
