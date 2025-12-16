# Роль Common

Базовая роль для настройки общих системных компонентов на серверах.

## Описание

Роль `common` выполняет базовую конфигурацию системы, включая:
- Настройка часового пояса
- Конфигурация системных параметров (sysctl)
- Настройка sudo
- Конфигурация NTP синхронизации времени
- Управление локалями системы
- Настройка hostname и DNS резолвинга

## Структура роли

```
roles/common/
├── defaults/
│   └── main.yml         # Переменные по умолчанию
├── handlers/
│   └── main.yml         # Обработчики событий
├── tasks/
│   ├── main.yml         # Основные задачи
│   ├── ntp.yml          # Настройка NTP
│   ├── locales.yml      # Управление локалями
│   └── resolv.yml       # Настройка DNS и hostname
├── templates/
│   ├── hosts.j2         # Шаблон /etc/hosts
│   ├── locale.j2        # Шаблон локалей
│   ├── ntp.conf.j2      # Конфигурация NTP
│   ├── ntp.j2           # Опции NTP демона
│   ├── resolv.conf.j2   # Конфигурация DNS
│   ├── sudoers.j2       # Конфигурация sudo
│   └── sysctl.conf.j2   # Параметры ядра
├── vars/
│   └── main.yml         # Внутренние переменные роли
└── README.md            # Документация роли
```

## Переменные

### Обязательные переменные

```yaml
# Часовой пояс
tz: "Europe/Moscow"

# Системные параметры sysctl
sysctl_default:
  net.ipv6.conf.default.disable_ipv6:
    value: 1
    state: present
  net.ipv6.conf.all.disable_ipv6:
    value: 1
    state: present
```

### Опциональные переменные

```yaml
# Дополнительные sysctl параметры
sysctl_custom:
  net.core.somaxconn:
    value: 4096
    state: present

# NTP сервер (по умолчанию debian.pool.ntp.org)
ntp_server: "pool.ntp.org"

# Локали для установки
common_locales_present_list:
  - lang: "en_US.UTF-8"
  - lang: "ru_RU.UTF-8"

# Локали для удаления
common_locales_absent_list:
  - lang: "fr_FR.UTF-8"

# Основная системная локаль
common_locales_lang: "en_US.UTF-8"

# Дополнительные LC переменные
common_locales_lc:
  lc_time: "ru_RU.UTF-8"
  lc_monetary: "ru_RU.UTF-8"


```

## Задачи

### 1. Timezone
Устанавливает системный часовой пояс используя модуль `community.general.timezone`.

### 2. Sysctl
Настраивает системные параметры ядра через `/etc/sysctl.d/local.conf`:
- Объединяет `sysctl_default` и `sysctl_custom` переменные
- Применяет параметры с помощью модуля `ansible.posix.sysctl`

### 3. Sudoers
Генерирует конфигурацию sudo из шаблона с поддержкой:
- Базовых настроек безопасности
- Группы sudo с полными правами
- Совместимости с разными версиями Debian

### 4. NTP
Настраивает синхронизацию времени:
- **Debian 12+**: Устанавливает `ntpsec`
- **Debian ≤11**: Устанавливает `ntp`
- Отключает IPv6 для NTP демона
- Настраивает NTP серверы через шаблон

### 5. Locales
Управляет системными локалями:
- Устанавливает пакет `locales`
- Генерирует указанные локали
- Удаляет ненужные локали
- Настраивает основную системную локаль

### 6. Hostname и DNS
Конфигурирует сетевые настройки:
- Устанавливает hostname из `inventory_hostname`
- Генерирует `/etc/hosts` с локальными записями
- Настраивает `/etc/resolv.conf` с DNS серверами

## Шаблоны

### hosts.j2
Шаблон `/etc/hosts`:
```
127.0.0.1   localhost
<IP>        <hostname>.local <hostname>
```

### ntp.conf.j2
Конфигурация NTP с:
- Настройкой pool серверов
- Ограничениями доступа
- Статистикой и логированием

### resolv.conf.j2
DNS конфигурация с серверами:
- Локальный DNS (IP хоста)
- Google DNS (8.8.8.8, 8.8.4.4)
- Cloudflare DNS (1.1.1.1, 1.0.0.1)
- Yandex DNS (77.88.8.8, 77.88.8.1)

### sudoers.j2
Безопасная конфигурация sudo с:
- Сбросом переменных окружения
- Уведомлениями о неудачных попытках
- Безопасным PATH

## Handlers

- `Reload sysctl` - Перезагружает sysctl параметры
- `Restart ntp` - Перезапускает NTP службу

## Теги

Все задачи помечены тегом `[common]` для селективного выполнения.

## Зависимости

### Ansible Collections
- `community.general` - для timezone и locale_gen
- `ansible.posix` - для sysctl

### Системные пакеты
- `locales` - для управления локалями
- `ntpsec` или `ntp` - для синхронизации времени

## Примеры использования

### Базовая конфигурация
```yaml
- hosts: all
  roles:
    - role: common
      vars:
        tz: "Europe/Moscow"
        sysctl_default:
          net.ipv6.conf.all.disable_ipv6:
            value: 1
            state: present
```

### Расширенная конфигурация
```yaml
- hosts: all
  roles:
    - role: common
      vars:
        tz: "UTC"
        ntp_server: "time.cloudflare.com"
        common_locales_present_list:
          - lang: "en_US.UTF-8"
          - lang: "ru_RU.UTF-8"
        common_locales_lang: "en_US.UTF-8"
        sysctl_custom:
          net.core.somaxconn:
            value: 8192
            state: present
          vm.swappiness:
            value: 10
            state: present
```

### Только определенные задачи
```bash
# Только NTP конфигурация
ansible-playbook -t common playbook.yml

# Только локали
ansible-playbook playbook.yml --skip-tags common
```

## Совместимость

- **OS**: Debian/Ubuntu
- **Ansible**: >= 2.9
- **Python**: >= 3.6

## Лицензия

MIT licensee

## Автор

aastlt
