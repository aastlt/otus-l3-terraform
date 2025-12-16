# Роль SSH

Роль для настройки SSH сервера с акцентом на безопасность. Автоматизирует конфигурацию SSH демона, управление портами, методами аутентификации и другими параметрами безопасности.

## Описание

Роль выполняет следующие задачи:
- Настройка SSH порта и адресов прослушивания
- Управление методами аутентификации (ключи, пароли)
- Настройка доступа для root пользователя
- Конфигурация дополнительных параметров безопасности
- Создание резервной копии конфигурации перед изменениями
- Автоматический перезапуск SSH сервиса при изменениях

## Структура файлов

```
roles/ssh/
├── defaults/main.yml         # Переменные по умолчанию
├── handlers/main.yml         # Обработчики событий
├── tasks/main.yml            # Основные задачи
├── templates/
│   └── sshd_config.j2        # Шаблон конфигурации SSH
└── README.md                 # Документация
```

## Требования

- Ansible >= 2.9
- Права sudo на целевом хосте
- SSH доступ к серверу (до применения изменений)
- Поддерживаемые ОС: Debian, Ubuntu, CentOS, RHEL

## Переменные роли

### Основные настройки (defaults/main.yml)

| Переменная | Тип | По умолчанию | Описание |
|------------|-----|--------------|----------|
| `ssh_port` | integer | `2222` | Порт SSH сервера |
| `ssh_permit_root_login` | boolean | `false` | Разрешить вход под root |
| `ssh_password_authentication` | boolean | `false` | Разрешить аутентификацию по паролю |
| `ssh_pubkey_authentication` | boolean | `true` | Разрешить аутентификацию по ключам |
| `ssh_users_default_shell` | string | `/bin/bash` | Оболочка по умолчанию для пользователей |

### Дополнительные переменные

| Переменная | Тип | По умолчанию | Описание |
|------------|-----|--------------|----------|
| `ssh_address_family` | string | `any` | Семейство адресов (any/inet/inet6) |
| `ssh_listen_address` | string | `0.0.0.0` | Адрес прослушивания |
| `ssh_challenge_response_auth` | boolean | `false` | Challenge-Response аутентификация |
| `ssh_use_pam` | boolean | `true` | Использовать PAM |
| `ssh_x11_forwarding` | boolean | `false` | Разрешить X11 forwarding |
| `ssh_print_motd` | boolean | `false` | Показывать MOTD |

## Использование

### Базовое использование

```yaml
- hosts: servers
  become: true
  roles:
    - ssh
```

### С настройкой переменных

```yaml
- hosts: servers
  become: true
  roles:
    - role: ssh
      vars:
        ssh_port: 22
        ssh_permit_root_login: false
        ssh_password_authentication: false
```

### Через group_vars

```yaml
# group_vars/all.yml
ssh_port: 2222
ssh_permit_root_login: false
ssh_password_authentication: false
ssh_pubkey_authentication: true
```

## Примеры конфигураций

### Высокая безопасность (рекомендуется)

```yaml
# group_vars/production.yml
ssh_port: 2222
ssh_permit_root_login: false
ssh_password_authentication: false
ssh_pubkey_authentication: true
ssh_x11_forwarding: false
ssh_challenge_response_auth: false
```

### Разработческая среда

```yaml
# group_vars/development.yml
ssh_port: 22
ssh_permit_root_login: true
ssh_password_authentication: true
ssh_pubkey_authentication: true
```

### Сервер с ограниченным доступом

```yaml
# host_vars/secure-server.yml
ssh_port: 9922
ssh_permit_root_login: false
ssh_password_authentication: false
ssh_pubkey_authentication: true
ssh_listen_address: "192.168.1.100"
```

### Переход с пароля на ключи

```yaml
# Этап 1: Разрешить оба метода
ssh_password_authentication: true
ssh_pubkey_authentication: true

# Этап 2: После настройки ключей отключить пароли
ssh_password_authentication: false
ssh_pubkey_authentication: true
```

## Шаблон конфигурации

Роль использует шаблон `sshd_config.j2` который включает:

- **Порт и адреса**: Настройка порта и адресов прослушивания
- **Аутентификация**: Управление методами входа
- **Безопасность**: Отключение небезопасных функций
- **PAM интеграция**: Поддержка системы аутентификации
- **SFTP подсистема**: Настройка файлового сервера

### Пример сгенерированной конфигурации

```
Port 2222
AddressFamily any
ListenAddress 0.0.0.0

# Authentication
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes

# Security
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
PrintMotd no

# Environment
AcceptEnv LANG LC_*

# Subsystems
Subsystem sftp /usr/lib/openssh/sftp-server
```

## Безопасность

⚠️ **Критически важные моменты:**

### 1. Порядок применения изменений

```yaml
# НЕПРАВИЛЬНО: Можете потерять доступ
- name: Change SSH port first
  include_role:
    name: ssh
  vars:
    ssh_port: 2222

# ПРАВИЛЬНО: Сначала настройте firewall
- name: Configure firewall first
  include_role:
    name: iptables
  vars:
    iptables_allowed_tcp_ports:
      - "22"    # Старый порт
      - "2222"  # Новый порт

- name: Then change SSH config
  include_role:
    name: ssh
  vars:
    ssh_port: 2222
```

### 2. Тестирование доступа

```bash
# Проверьте новое соединение в отдельном терминале
ssh -p 2222 user@server

# Только после успешного подключения закройте старый порт
```

### 3. Резервный доступ

- Всегда имейте консольный доступ к серверу
- Настройте мониторинг SSH сервиса
- Создайте процедуру восстановления

### 4. Управление ключами

```yaml
# Убедитесь, что ключи настроены перед отключением паролей
- name: Setup SSH keys first
  authorized_key:
    user: "{{ ansible_user }}"
    key: "{{ ssh_public_key }}"
    state: present

- name: Then disable password auth
  include_role:
    name: ssh
  vars:
    ssh_password_authentication: false
```

## Устранение неполадок

### Потерян SSH доступ

```bash
# Через консоль сервера
sudo systemctl status ssh
sudo journalctl -u ssh -f

# Восстановление конфигурации
sudo cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
sudo systemctl restart ssh
```

### Проверка конфигурации

```bash
# Проверка синтаксиса конфигурации
sudo sshd -t

# Просмотр активной конфигурации
sudo sshd -T

# Проверка портов
sudo netstat -tlnp | grep sshd
sudo ss -tlnp | grep sshd
```

### Отладка подключений

```bash
# Подробный вывод клиента
ssh -vvv -p 2222 user@server

# Логи сервера
sudo tail -f /var/log/auth.log
sudo journalctl -u ssh -f
```

### Проблемы с ключами

```bash
# Проверка прав на файлы
ls -la ~/.ssh/
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# Проверка ключа
ssh-keygen -l -f ~/.ssh/id_rsa.pub
```

## Теги

Роль поддерживает следующие теги:

- `ssh` - все задачи роли

```bash
# Выполнить только SSH конфигурацию
ansible-playbook playbook.yml --tags ssh

# Пропустить SSH конфигурацию
ansible-playbook playbook.yml --skip-tags ssh
```

## Примеры плейбуков

### Безопасная настройка SSH

```yaml
---
- name: Secure SSH configuration
  hosts: all
  become: true
  
  vars:
    # Сначала настраиваем firewall
    iptables_allowed_tcp_ports:
      - "22"    # Текущий SSH
      - "2222"  # Новый SSH
    
    # Затем SSH конфигурацию
    ssh_port: 2222
    ssh_permit_root_login: false
    ssh_password_authentication: false
    ssh_pubkey_authentication: true
  
  tasks:
    - name: Configure firewall first
      include_role:
        name: iptables
    
    - name: Configure SSH
      include_role:
        name: ssh
    
    - name: Test new SSH connection
      wait_for:
        host: "{{ inventory_hostname }}"
        port: "{{ ssh_port }}"
        timeout: 30
      delegate_to: localhost
```

### Поэтапная миграция

```yaml
---
# Этап 1: Подготовка
- name: Stage 1 - Prepare
  hosts: servers
  become: true
  roles:
    - role: ssh
      vars:
        ssh_port: 22
        ssh_password_authentication: true
        ssh_pubkey_authentication: true

# Этап 2: Настройка ключей (выполняется вручную)

# Этап 3: Отключение паролей
- name: Stage 3 - Disable passwords
  hosts: servers
  become: true
  roles:
    - role: ssh
      vars:
        ssh_port: 22
        ssh_password_authentication: false
        ssh_pubkey_authentication: true

# Этап 4: Смена порта
- name: Stage 4 - Change port
  hosts: servers
  become: true
  roles:
    - role: ssh
      vars:
        ssh_port: 2222
        ssh_password_authentication: false
        ssh_pubkey_authentication: true
```

## Интеграция с другими ролями

### С ролью users

```yaml
- name: Setup users and SSH
  hosts: servers
  become: true
  
  roles:
    - role: users
      vars:
        users_list:
          - name: admin
            groups: sudo
            ssh_key: "ssh-rsa AAAAB3..."
    
    - role: ssh
      vars:
        ssh_permit_root_login: false
        ssh_password_authentication: false
```

### С ролью iptables

```yaml
- name: Secure server setup
  hosts: servers
  become: true
  
  vars:
    ssh_port: 2222
  
  roles:
    - role: iptables
      vars:
        iptables_allowed_tcp_ports:
          - "{{ ssh_port }}"
    
    - role: ssh
```

## Совместимость

- **Debian**: 9, 10, 11, 12
- **Ubuntu**: 18.04, 20.04, 22.04, 24.04
- **CentOS**: 7, 8, 9
- **RHEL**: 7, 8, 9

## Зависимости

Роль не имеет зависимостей от других ролей, но рекомендуется использовать совместно с:
- `iptables` - для настройки firewall
- `users` - для управления пользователями

## Лицензия

MITMIT licensee

## Автор

aastlt
