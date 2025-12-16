# OTUS L3 Terraform Project

Проект для автоматизированного развертывания инфраструктуры в Yandex Cloud с использованием Terraform и Ansible.

## Описание

Проект создает виртуальную машину в Yandex Cloud и автоматически настраивает ее с помощью Ansible playbooks. Включает настройку сети, дисков, SSH доступа и базовую конфигурацию системы.

## Архитектура

- **Провайдер**: Yandex Cloud
- **ОС**: Debian 11
- **Автоматизация**: Terraform + Ansible
- **Сеть**: VPC с NAT gateway

## Структура проекта

```
otus-l3-terraform/
├── main.tf               # Основная конфигурация VM
├── variables.tf          # Переменные проекта
├── providers.tf          # Конфигурация провайдеров
├── resources.tf          # Дополнительные ресурсы (диски, сеть)
├── output.tf             # Выходные значения
├── ansible.tf            # Интеграция с Ansible
├── locals.tf             # Локальные переменные
├── templates/
│   └── inventory.tpl     # Шаблон Ansible inventory
├── bootstrap/            # Ansible playbooks и роли
│   ├── bootstrap.yml     # Основной playbook
│   ├── ansible.cfg       # Конфигурация Ansible
│   └── roles/            # Ansible роли
└── personal.auto.tfvars  # Персональные переменные (не в git)
```

## Требования

### Системные требования
- Terraform >= 1.0
- Ansible >= 2.9
- SSH клиент

### Yandex Cloud
- Активный аккаунт Yandex Cloud
- OAuth токен
- Настроенный CLI `yc`

## Установка и настройка

### 1. Клонирование проекта
```bash
git clone https://github.com/aastlt/otus-l3-terraform.git
cd otus-l3-terraform
```

### 2. Настройка переменных
Создайте файл `personal.auto.tfvars`:
```hcl
token     = "your-oauth-token"
cloud_id  = "your-cloud-id"
folder_id = "your-folder-id"
```

### 3. Настройка SSH ключей
```bash
# Генерация SSH ключа (если нет)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa

# Убедитесь что путь к публичному ключу правильный в variables.tf
```

## Использование

> **Примечание**: Проект настроен для работы с планом `otus-l3-terraform_plan` для безопасного развертывания.

### Инициализация Terraform
```bash
terraform init
```

### Планирование изменений
```bash
terraform plan
```

### Применение конфигурации
```bash
terraform apply
terraform apply otus-l3-terraform_plan # применить готовый план
```

### Уничтожение инфраструктуры
```bash
terraform destroy
```

## Конфигурация

### Основные переменные

| Переменная | Описание | По умолчанию |
|------------|----------|--------------|
| `vm_name` | Имя виртуальной машины | `otus-l3-terraform` |
| `default_zone` | Зона размещения | `ru-central1-b` |
| `image_id` | ID образа ОС | `fd8oees0esvl0qf4lp59` (Debian 11) |
| `ssh_user` | Пользователь для SSH | `debian` |
| `domain` | Доменное имя | `local` |

### Ресурсы VM
```hcl
vm_resources_list = [
  {
    vm_name       = "otus-l3-terraform"
    cpu           = 2
    ram           = 2
    gpus          = 0
    disk          = 1
    core_fraction = 5
  }
]
```

## Ansible Bootstrap

Проект использует Ansible для автоматической настройки виртуальной машины после создания. Подробная документация по настройке и использованию Ansible доступна в **[bootstrap/README.md](bootstrap/README.md)**.

### Ansible роли

Проект включает следующие Ansible роли:

- **[apt](bootstrap/roles/apt/README.md)** - Обновление пакетов
- **[common](bootstrap/roles/common/README.md)** - Базовая настройка системы
- **[users](bootstrap/roles/users/README.md)** - Управление пользователями
- **[ssh](bootstrap/roles/ssh/README.md)** - Настройка SSH
- **[iptables](bootstrap/roles/iptables/README.md)** - Настройка файрвола

## Выходные данные

После успешного применения Terraform выводит:

- `instance_id` - ID виртуальной машины
- `internal_ip_address_vm_1` - Внутренний IP адрес
- `external_ip_address_vm_1` - Внешний IP адрес
- `instance_hostname_fqdn` - FQDN хоста

## Troubleshooting

### Проблемы с Ansible
```bash
# Проверка подключения
ansible all -i bootstrap/inventory/hosts -m ping

# Запуск playbook вручную
cd bootstrap
ansible-playbook -i inventory/hosts bootstrap.yml -v
```

### Проблемы с SSH
```bash
# Проверка SSH подключения
ssh -i ~/.ssh/id_rsa debian@<external_ip>

# Отладка SSH
ssh -vvv -i ~/.ssh/id_rsa debian@<external_ip>
```

### Логи Terraform
```bash
export TF_LOG=DEBUG
terraform apply
```

## Безопасность

- SSH ключи не хранятся в репозитории
- Используется OAuth токен для аутентификации
- Настроен файрвол через iptables
- Отключена аутентификация по паролю

## Лицензия

MIT License

## Автор

aastlt
