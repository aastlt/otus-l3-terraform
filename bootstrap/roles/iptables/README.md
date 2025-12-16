# Роль iptables

Роль для настройки базового файрвола iptables на серверах Linux. Автоматизирует установку, конфигурацию и управление правилами iptables с поддержкой IPv4 и IPv6.

## Описание

Роль выполняет следующие задачи:
- Установка пакетов iptables и сопутствующих утилит
- Отключение конфликтующих файрволов (firewalld, ufw)
- Настройка базовых правил безопасности
- Конфигурация портов для входящих соединений
- Настройка проброса портов
- Защита от сканирования портов
- Логирование отброшенных пакетов
- Поддержка IPv6

## Структура файлов

```
roles/iptables/
├── defaults/main.yml            # Переменные по умолчанию
├── handlers/main.yml            # Обработчики событий
├── tasks/
│   ├── main.yml                 # Основные задачи
│   ├── 01_install.yml           # Установка пакетов
│   ├── 02_configure.yml         # Конфигурация правил
│   └── 03_disable_other_fw.yml  # Отключение других файрволов
├── templates/
│   ├── firewall.bash.j2         # Шаблон скрипта правил
│   ├── firewall.init.j2         # Init скрипт
│   └── firewall.unit.j2         # Systemd unit
└── vars/                        # Переменные для разных ОС
    ├── Debian.yml
    ├── Ubuntu.yml
    ├── RedHat.yml
    └── Archlinux.yml
```

## Требования

- Ansible >= 2.9
- Права sudo на целевом хосте
- Поддерживаемые ОС: Debian, Ubuntu, CentOS, RHEL, Arch Linux

## Переменные роли

### Основные настройки

| Переменная | Тип | По умолчанию | Описание |
|------------|-----|--------------|----------|
| `iptables_state` | string | `started` | Состояние сервиса iptables |
| `iptables_enabled` | boolean | `true` | Автозапуск сервиса при загрузке |
| `iptables_install_method` | string | `package` | Метод установки (package/script) |
| `iptables_template` | string | `firewall.bash.j2` | Шаблон для генерации правил |

### Управление правилами

| Переменная | Тип | По умолчанию | Описание |
|------------|-----|--------------|----------|
| `iptables_flush_rules_and_chains` | boolean | `true` | Очищать правила при перезапуске |
| `iptables_allowed_tcp_ports` | list | `["50022"]` | Разрешенные TCP порты |
| `iptables_allowed_udp_ports` | list | `[]` | Разрешенные UDP порты |
| `iptables_forwarded_tcp_ports` | list | `[]` | Проброс TCP портов |
| `iptables_forwarded_udp_ports` | list | `[]` | Проброс UDP портов |
| `iptables_additional_rules` | list | `[]` | Дополнительные правила IPv4 |

### Дополнительные опции

| Переменная | Тип | По умолчанию | Описание |
|------------|-----|--------------|----------|
| `iptables_log_dropped_packets` | boolean | `true` | Логировать отброшенные пакеты |
| `iptables_enable_ipv6` | boolean | `true` | Включить поддержку IPv6 |
| `iptables_ip6_additional_rules` | list | `[]` | Дополнительные правила IPv6 |
| `iptables_disable_firewalld` | boolean | `false` | Отключить firewalld |
| `iptables_disable_ufw` | boolean | `false` | Отключить ufw |

## Использование

### Базовое использование

```yaml
- hosts: servers
  become: true
  roles:
    - iptables
```

### С настройкой портов

```yaml
- hosts: webservers
  become: true
  roles:
    - role: iptables
      vars:
        iptables_allowed_tcp_ports:
          - "22"    # SSH
          - "80"    # HTTP
          - "443"   # HTTPS
          - "8080"  # Custom app
        iptables_allowed_udp_ports:
          - "53"    # DNS
```

### С пробросом портов

```yaml
- hosts: proxy
  become: true
  roles:
    - role: iptables
      vars:
        iptables_forwarded_tcp_ports:
          - { src: "80", dest: "8080" }
          - { src: "443", dest: "8443" }
```

### С дополнительными правилами

```yaml
- hosts: database
  become: true
  roles:
    - role: iptables
      vars:
        iptables_additional_rules:
          - "iptables -A INPUT -p tcp --dport 3306 -s 192.168.1.0/24 -j ACCEPT"
          - "iptables -A INPUT -p tcp --dport 5432 -s 10.0.0.0/8 -j ACCEPT"
```

## Примеры конфигураций

### Веб-сервер

```yaml
# group_vars/webservers.yml
iptables_allowed_tcp_ports:
  - "22"     # SSH
  - "80"     # HTTP
  - "443"    # HTTPS

iptables_log_dropped_packets: true
iptables_disable_ufw: true
```

### База данных

```yaml
# group_vars/databases.yml
iptables_allowed_tcp_ports:
  - "22"     # SSH
  - "3306"   # MySQL

iptables_additional_rules:
  # Разрешить доступ только с веб-серверов
  - "iptables -A INPUT -p tcp --dport 3306 -s 192.168.1.10 -j ACCEPT"
  - "iptables -A INPUT -p tcp --dport 3306 -s 192.168.1.11 -j ACCEPT"
  - "iptables -A INPUT -p tcp --dport 3306 -j DROP"
```

### Прокси-сервер

```yaml
# host_vars/proxy.yml
iptables_allowed_tcp_ports:
  - "22"     # SSH
  - "80"     # HTTP
  - "443"    # HTTPS
  - "8080"   # Proxy

iptables_forwarded_tcp_ports:
  - { src: "80", dest: "8080" }
  - { src: "443", dest: "8443" }
```

### Отключение IPv6

```yaml
# Для систем без IPv6
iptables_enable_ipv6: false
```

## Безопасность

⚠️ **Важные моменты:**

1. **SSH доступ**: Убедитесь, что SSH порт открыт перед применением правил
2. **Тестирование**: Всегда тестируйте на тестовом сервере
3. **Резервный доступ**: Имейте альтернативный способ доступа к серверу
4. **Логирование**: Включите логирование для отладки

### Пример безопасной конфигурации SSH

```yaml
iptables_allowed_tcp_ports:
  - "22"     # Стандартный SSH
  - "2222"   # Альтернативный SSH

# Ограничить SSH доступ по IP
iptables_additional_rules:
  - "iptables -A INPUT -p tcp --dport 22 -s 192.168.1.0/24 -j ACCEPT"
  - "iptables -A INPUT -p tcp --dport 22 -j DROP"
```

## Устранение неполадок

### Потерян SSH доступ

```bash
# Через консоль сервера
sudo iptables -F INPUT
sudo iptables -P INPUT ACCEPT
sudo systemctl restart iptables
```

### Проверка правил

```bash
# Просмотр текущих правил
sudo iptables -L -n -v

# Просмотр логов
sudo tail -f /var/log/syslog | grep iptables
```

### Отладка роли

```bash
# Запуск с подробным выводом
ansible-playbook -vvv playbook.yml --tags iptables

# Проверка синтаксиса
ansible-playbook --syntax-check playbook.yml
```

## Теги

Роль поддерживает следующие теги:

- `iptables` - все задачи роли
- `iptables-install` - только установка
- `iptables-configure` - только конфигурация
- `iptables-disable-fw` - отключение других файрволов

```bash
# Выполнить только установку
ansible-playbook playbook.yml --tags iptables-install

# Пропустить отключение других файрволов
ansible-playbook playbook.yml --skip-tags iptables-disable-fw
```

## Совместимость

- **Debian**: 9, 10, 11, 12
- **Ubuntu**: 18.04, 20.04, 22.04, 24.04
- **CentOS**: 7, 8, 9
- **RHEL**: 7, 8, 9
- **Arch Linux**: текущая версия

## Зависимости

Роль не имеет зависимостей от других ролей.

## Лицензия

MIT licensee

## Автор

aastlt
