# Роль APT

Роль для управления пакетами APT в системах на базе Debian/Ubuntu. Автоматизирует обновление кэша пакетов, обновление системы и установку/удаление необходимых пакетов.

## Описание

Роль выполняет следующие задачи:
- Обновление кэша пакетов APT
- Обновление установленных пакетов системы
- Установка базового набора системных пакетов
- Удаление нежелательных пакетов

## Структура файлов

```
roles/apt/
├── defaults/main.yml         # Переменные по умолчанию
├── tasks/main.yml            # Основные задачи
├── vars/main.yml             # Списки пакетов
├── templates/                # Шаблоны (если необходимо)
└── README.md                 # Документация
```

## Требования

- Ansible >= 2.9
- Система на базе Debian/Ubuntu
- Права sudo на целевом хосте

## Переменные роли

### Основные переменные (defaults/main.yml)

| Переменная | Тип | По умолчанию | Описание |
|------------|-----|--------------|----------|
| `apt_update_cache` | boolean | `true` | Обновлять кэш пакетов APT |
| `apt_upgrade` | boolean | `true` | Выполнять обновление пакетов |

### Переменные пакетов (vars/main.yml)

| Переменная | Тип | Описание |
|------------|-----|----------|
| `apt_packages_default` | list | Список пакетов для установки |
| `apt_packages_absent_default` | list | Список пакетов для удаления |

## Устанавливаемые пакеты

### Базовые системные пакеты:
- **Системные утилиты**: bash-completion, coreutils, findutils, diffutils
- **Сетевые инструменты**: curl, dnsutils, net-tools, rsync
- **Мониторинг**: htop, iotop, sysstat, smartmontools
- **Безопасность**: ca-certificates, gnupg, gnupg2, openssl, sudo
- **Разработка**: git, python3, python3-pip, python3-apt
- **Архивация**: bzip2, gnutls-bin
- **Редакторы**: mc, less, tmux, screen
- **Системные сервисы**: systemd-timesyncd, rsyslog, logrotate
- **Сеть и файрвол**: iptables, iptables-persistent

### Удаляемые пакеты:
- **Почтовые сервисы**: mailutils, exim4*

## Использование

### Базовое использование

```yaml
- hosts: servers
  become: true
  roles:
    - apt
```

### С настройкой переменных

```yaml
- hosts: servers
  become: true
  roles:
    - role: apt
      vars:
        apt_update_cache: true
        apt_upgrade: false
```

### Переопределение списка пакетов

```yaml
# group_vars/all.yml
apt_packages_default:
  - htop
  - git
  - curl
  - python3

apt_packages_absent_default:
  - nano
  - vim-tiny
```

### Добавление дополнительных пакетов

```yaml
# host_vars/webserver.yml
apt_packages_additional:
  - nginx
  - php-fpm
  - mysql-client
```

## Теги

Роль поддерживает следующие теги:

- `apt` - выполнить все задачи роли

```bash
# Выполнить только задачи APT
ansible-playbook playbook.yml --tags apt

# Пропустить задачи APT
ansible-playbook playbook.yml --skip-tags apt
```

## Примеры плейбуков

### Минимальная установка

```yaml
---
- name: Install basic packages
  hosts: all
  become: true
  
  roles:
    - role: apt
      vars:
        apt_upgrade: false
        apt_packages_default:
          - htop
          - git
          - curl
```

### Полная настройка сервера

```yaml
---
- name: Bootstrap server
  hosts: servers
  become: true
  
  vars:
    apt_packages_default:
      - htop
      - iotop
      - git
      - curl
      - python3
      - python3-pip
      - nginx
      - ufw
    
    apt_packages_absent_default:
      - apache2
      - sendmail
  
  roles:
    - apt
```

### Только обновление без установки пакетов

```yaml
---
- name: Update system packages
  hosts: all
  become: true
  
  roles:
    - role: apt
      vars:
        apt_packages_default: []
        apt_packages_absent_default: []
```

## Зависимости

Роль не имеет зависимостей от других ролей.

## Совместимость

- **Debian**: 9, 10, 11, 12
- **Ubuntu**: 18.04, 20.04, 22.04, 24.04

## Лицензия

MIT licensee

## Автор

aastlt
