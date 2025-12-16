# Роль Users

Роль для управления пользователями системы, их SSH ключами и правами sudo. Автоматизирует создание пользователей, настройку групп, управление SSH авторизованными ключами и конфигурацию sudo доступа.

## Описание

Роль выполняет следующие задачи:
- Создание и удаление пользователей системы
- Управление группами пользователей
- Настройка SSH авторизованных ключей
- Конфигурация sudo доступа без пароля
- Управление домашними директориями
- Настройка оболочек пользователей
- Управление UID и комментариями

## Структура файлов

```
roles/users/
├── defaults/main.yml         # Переменные по умолчанию
├── tasks/main.yml            # Основные задачи
└── README.md                 # Документация
```

## Требования

- Ansible >= 2.9
- Коллекция ansible.posix (для authorized_key)
- Права sudo на целевом хосте
- Поддерживаемые ОС: Debian, Ubuntu, CentOS, RHEL

## Переменные роли

### Основные переменные (defaults/main.yml)

| Переменная | Тип | По умолчанию | Описание |
|------------|-----|--------------|----------|
| `users_default_shell` | string | `/bin/bash` | Оболочка по умолчанию для пользователей |
| `users_default_remove` | boolean | `false` | Удалять домашние директории при удалении пользователей |
| `users_default_force` | boolean | `false` | Принудительное удаление пользователей |

### Переменные конфигурации

| Переменная | Тип | Описание |
|------------|-----|----------|
| `users_list` | list | Список определений пользователей |
| `users_groups_list` | list | Список групп для создания/удаления |

## Структура пользователя

Каждый пользователь в `users_list` может содержать следующие параметры:

| Параметр | Тип | Обязательный | Описание |
|----------|-----|--------------|----------|
| `name` | string | ✓ | Имя пользователя |
| `state` | string | | Состояние (present/absent) |
| `groups` | list | | Список групп пользователя |
| `ssh_keys` | list | | SSH публичные ключи |
| `sudo_nopassword` | boolean | | Sudo без пароля |
| `shell` | string | | Оболочка пользователя |
| `uid` | integer | | UID пользователя |
| `comment` | string | | Комментарий (GECOS) |
| `password` | string | | Хешированный пароль |

## Использование

### Базовое использование

```yaml
- hosts: servers
  become: true
  roles:
    - users
```

### С определением пользователей

```yaml
- hosts: servers
  become: true
  roles:
    - role: users
      vars:
        users_list:
          - name: admin
            groups: [sudo]
            ssh_keys:
              - "ssh-rsa AAAAB3NzaC1yc2E... admin@laptop"
            sudo_nopassword: true
```

### Через group_vars

```yaml
# group_vars/all.yml
users_list:
  - name: alice
    state: present
    groups: [sudo, developers]
    ssh_keys:
      - "ssh-rsa AAAAB3... alice@laptop"
      - "ssh-ed25519 AAAAC3... alice@desktop"
    sudo_nopassword: true
    comment: "Alice Developer"
  
  - name: bob
    state: present
    groups: [users]
    shell: /bin/zsh
    uid: 1001
```

## Примеры конфигураций

### Администраторы сервера

```yaml
# group_vars/production.yml
users_list:
  - name: admin
    groups: [sudo, adm]
    ssh_keys:
      - "ssh-rsa AAAAB3... admin@workstation"
    sudo_nopassword: true
    comment: "System Administrator"
  
  - name: backup
    groups: [backup]
    shell: /bin/sh
    comment: "Backup Service User"
```

### Разработчики

```yaml
# group_vars/developers.yml
users_list:
  - name: dev1
    groups: [developers, docker]
    ssh_keys:
      - "ssh-ed25519 AAAAC3... dev1@laptop"
    sudo_nopassword: false
    shell: /bin/zsh
  
  - name: dev2
    groups: [developers]
    ssh_keys:
      - "ssh-rsa AAAAB3... dev2@home"
    shell: /bin/fish
```

### Удаление пользователей

```yaml
# Удаление старых пользователей
users_list:
  - name: olduser
    state: absent
  
  - name: tempuser
    state: absent
```

### Сервисные пользователи

```yaml
# Пользователи для сервисов
users_list:
  - name: nginx
    groups: [www-data]
    shell: /bin/false
    comment: "Nginx web server"
  
  - name: postgres
    groups: [postgres]
    shell: /bin/bash
    comment: "PostgreSQL database user"
```

### Управление группами

```yaml
# Создание дополнительных групп
users_groups_list:
  - name: developers
    state: present
  
  - name: testers
    state: present
  
  - name: oldgroup
    state: absent

users_list:
  - name: alice
    groups: [developers, sudo]
    ssh_keys:
      - "ssh-rsa AAAAB3... alice@laptop"
```

## Безопасность

⚠️ **Важные моменты безопасности:**

### 1. SSH ключи

```yaml
# ПРАВИЛЬНО: Используйте современные ключи
users_list:
  - name: admin
    ssh_keys:
      - "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5... admin@secure"
      - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... admin@backup"

# ИЗБЕГАЙТЕ: Слабые или старые ключи
```

### 2. Sudo доступ

```yaml
# Ограничьте sudo доступ
users_list:
  - name: admin
    groups: [sudo]
    sudo_nopassword: true  # Только для доверенных пользователей
  
  - name: developer
    groups: [developers]
    sudo_nopassword: false  # Требует пароль для sudo
```

### 3. Управление паролями

```yaml
# Используйте хешированные пароли
users_list:
  - name: user1
    password: "$6$rounds=656000$salt$hash..."  # mkpasswd --method=sha-512
    ssh_keys:
      - "ssh-ed25519 AAAAC3... user1@laptop"
```

### 4. Аудит пользователей

```yaml
# Регулярно проверяйте и удаляйте неиспользуемых пользователей
users_list:
  - name: inactive_user
    state: absent
  
  - name: contractor
    state: absent  # Удалить после завершения проекта
```

## Примеры плейбуков

### Настройка команды разработки

```yaml
---
- name: Setup development team
  hosts: dev_servers
  become: true
  
  vars:
    users_groups_list:
      - name: developers
      - name: docker
    
    users_list:
      - name: alice
        groups: [developers, docker, sudo]
        ssh_keys:
          - "ssh-ed25519 AAAAC3... alice@laptop"
        sudo_nopassword: true
        comment: "Lead Developer"
      
      - name: bob
        groups: [developers]
        ssh_keys:
          - "ssh-rsa AAAAB3... bob@workstation"
        shell: /bin/zsh
        comment: "Junior Developer"
  
  roles:
    - users
```

### Безопасная настройка сервера

```yaml
---
- name: Secure server setup
  hosts: production
  become: true
  
  vars:
    users_list:
      # Создать администратора
      - name: sysadmin
        groups: [sudo, adm]
        ssh_keys:
          - "ssh-ed25519 AAAAC3... sysadmin@secure"
        sudo_nopassword: true
        comment: "System Administrator"
      
      # Удалить пользователя по умолчанию
      - name: ubuntu
        state: absent
      
      # Создать пользователя для мониторинга
      - name: monitoring
        groups: [monitoring]
        shell: /bin/sh
        comment: "Monitoring Service"
  
  tasks:
    - name: Setup users
      include_role:
        name: users
    
    - name: Disable root login after admin setup
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^PermitRootLogin'
        line: 'PermitRootLogin no'
      notify: restart ssh
```

### Миграция пользователей

```yaml
---
- name: Migrate users from old system
  hosts: new_servers
  become: true
  
  vars:
    # Импорт пользователей с сохранением UID
    users_list:
      - name: alice
        uid: 1001
        groups: [sudo]
        ssh_keys:
          - "{{ alice_ssh_key }}"
        sudo_nopassword: true
      
      - name: bob
        uid: 1002
        groups: [developers]
        ssh_keys:
          - "{{ bob_ssh_key }}"
  
  roles:
    - users
```

## Интеграция с другими ролями

### С ролью SSH

```yaml
- name: Setup users and secure SSH
  hosts: servers
  become: true
  
  roles:
    - role: users
      vars:
        users_list:
          - name: admin
            groups: [sudo]
            ssh_keys:
              - "ssh-ed25519 AAAAC3... admin@laptop"
            sudo_nopassword: true
    
    - role: ssh
      vars:
        ssh_permit_root_login: false
        ssh_password_authentication: false
```

### С ролью iptables

```yaml
- name: Secure server with users and firewall
  hosts: servers
  become: true
  
  roles:
    - role: users
    - role: iptables
      vars:
        iptables_allowed_tcp_ports:
          - "22"  # SSH для созданных пользователей
    - role: ssh
```

## Устранение неполадок

### Проблемы с SSH ключами

```bash
# Проверка прав на файлы
ls -la /home/username/.ssh/
sudo chmod 700 /home/username/.ssh
sudo chmod 600 /home/username/.ssh/authorized_keys
sudo chown username:username /home/username/.ssh/authorized_keys
```

### Проблемы с sudo

```bash
# Проверка sudoers файлов
sudo visudo -c
ls -la /etc/sudoers.d/
sudo cat /etc/sudoers.d/username
```

### Проверка пользователей

```bash
# Список пользователей
getent passwd
id username
groups username

# Проверка групп
getent group
```

### Отладка роли

```bash
# Запуск с подробным выводом
ansible-playbook -vvv playbook.yml --tags users

# Проверка в check mode
ansible-playbook --check --diff playbook.yml --tags users
```

## Теги

Роль поддерживает следующие теги:

- `users` - все задачи роли

```bash
# Выполнить только управление пользователями
ansible-playbook playbook.yml --tags users

# Пропустить управление пользователями
ansible-playbook playbook.yml --skip-tags users
```

## Совместимость

- **Debian**: 9, 10, 11, 12
- **Ubuntu**: 18.04, 20.04, 22.04, 24.04
- **CentOS**: 7, 8, 9
- **RHEL**: 7, 8, 9

## Зависимости

- **ansible.posix** коллекция (для authorized_key модуля)

```bash
# Установка зависимостей
ansible-galaxy collection install ansible.posix
```

## Лицензия

MIT licensee

## Автор

aastlt
