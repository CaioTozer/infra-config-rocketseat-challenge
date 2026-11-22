# Infraestrutura AWS com Terraform

Projeto Terraform modular para provisionar rede (VPC) e uma instância **Amazon EC2** na região **us-east-1**, com estado remoto no **Amazon S3**.

## Visão geral da arquitetura

```text
                    Internet
                        │
                        ▼
              ┌─────────────────┐
              │ Internet Gateway │  (módulo VPC)
              └────────┬────────┘
                       │
         ┌─────────────▼─────────────┐
         │  VPC 10.0.0.0/16          │
         │  Subnet pública 10.0.1.0/24│  AZ: us-east-1a
         │  map_public_ip_on_launch   │
         └─────────────┬─────────────┘
                       │
                       ▼
              ┌─────────────────┐
              │  EC2 (t3.micro)  │  Nome: terraform-ec2
              └─────────────────┘

Módulo ALB (presente no repositório, ainda não referenciado no root):
  ALB → Target Group (HTTP:80) → anexo à instância EC2
```

| Componente | Recurso AWS | Configuração atual |
|------------|-------------|-------------------|
| Região | — | `us-east-1` (`provider.tf`) |
| Estado | S3 | Bucket `my-terraform-state`, chave `terraform/dev/terraform.tfstate`, criptografia e lockfile |
| VPC | `aws_vpc` | CIDR `10.0.0.0/16`, DNS habilitado |
| Sub-rede | `aws_subnet` | `10.0.1.0/24`, subnet pública (IP público na subida) |
| Gateway | `aws_internet_gateway` | Anexado à VPC |
| EC2 | `aws_instance` | `t3.micro`, AMI e rede via parâmetros do módulo |

### Especificação da máquina (EC2)

| Atributo | Valor no `main.tf` raiz |
|----------|-------------------------|
| **Tipo** | `t3.micro` (2 vCPU burstable, 1 GiB RAM — tier Free Tier elegível em contas novas, conforme política AWS) |
| **Nome (tag)** | `terraform-ec2` |
| **AMI** | Placeholder `ami-0abcdef1234567890` — **substitua** por uma AMI válida em `us-east-1` (ex.: Amazon Linux 2023) |
| **Sub-rede** | Placeholder `subnet-12345678` — idealmente use a saída `module.vpc.subnet_id` |
| **Security Groups** | Placeholder `sg-12345678` — ainda não há recurso `aws_security_group` neste projeto |

**Outputs disponíveis após o `apply`:** `ec2_instance_id`, `ec2_private_ip`, `ec2_public_ip`.

## Estrutura do repositório

```text
terraform/
├── main.tf              # Backend S3 + chamadas aos módulos vpc e ec2
├── provider.tf          # Provider AWS e versões
├── outputs.tf           # Outputs da instância EC2
└── modules/
    ├── VPC/             # VPC, subnet pública, Internet Gateway
    ├── EC2/             # Instância EC2
    └── ALB/             # Application Load Balancer (não usado no root ainda)
```

## Pré-requisitos

1. [Terraform](https://developer.hashicorp.com/terraform/install) **>= 1.10.0**
2. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configurado (`aws configure` ou variáveis de ambiente / IAM role)
3. Bucket S3 **`my-terraform-state`** criado em `us-east-1` (ou ajuste o bloco `backend` em `main.tf`)
4. Permissões IAM para VPC, EC2, S3 (estado) e, se usar ALB, ELB

### Credenciais AWS (exemplos)

```bash
export AWS_PROFILE=seu-perfil
# ou
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=us-east-1
```

## Comandos Terraform — subir as instâncias EC2

Execute a partir do diretório `terraform/`:

```bash
cd terraform
```

| Etapa | Comando | Descrição |
|-------|---------|-----------|
| 1 | `terraform init` | Baixa o provider AWS e configura o backend S3 |
| 2 | `terraform fmt -recursive` | Formata os arquivos `.tf` (opcional, recomendado) |
| 3 | `terraform validate` | Valida sintaxe e consistência |
| 4 | `terraform plan` | Mostra o que será criado/alterado (VPC + EC2 conforme o código atual) |
| 5 | `terraform apply` | Aplica as mudanças e **cria** os recursos |
| 6 | `terraform output` | Exibe IPs e ID da instância após o apply |

### Fluxo completo (criar infraestrutura)

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
terraform output
```

### Comandos úteis no dia a dia

```bash
# Ver estado dos recursos gerenciados
terraform state list

# Detalhes da instância EC2 no state
terraform state show 'module.ec2.aws_instance.this'

# Atualizar apenas o módulo EC2 (após mudanças no código)
terraform plan -target=module.ec2
terraform apply -target=module.ec2

# Destruir tudo (cuidado em produção)
terraform destroy
```

### Primeira execução com backend S3

Se o bucket ainda não existir, você pode:

- Criar o bucket manualmente ou com outro stack, **ou**
- Comentar temporariamente o bloco `backend "s3"` e rodar `terraform init` com estado local, depois migrar com `terraform init -migrate-state`.

## Avaliação do código (resumo)

**Pontos positivos**

- Separação em módulos (`VPC`, `EC2`, `ALB`) com variáveis, outputs e tags nomeadas.
- Estado remoto S3 com criptografia e lockfile (boa prática para equipe/CI).
- Provider AWS pinado (`~> 6.0`) e versão mínima do Terraform definida.
- Subnet configurada para IP público na criação da instância.

**Pontos de atenção antes do apply em conta real**

1. **EC2 desacoplada da VPC:** em `main.tf`, `subnet_id` e `security_group_ids` são placeholders e **não** usam `module.vpc`. O `plan` pode falhar ou criar a EC2 na rede errada. Recomendação: passar `subnet_id = module.vpc.subnet_id` e criar/usar security groups no mesmo stack.
2. **AMI inválida:** troque `ami_id` por uma AMI real da sua região (consulte `aws ec2 describe-images` ou o console EC2).
3. **Roteamento público incompleto:** existe Internet Gateway, mas **não** há `aws_route_table` / associação com rota `0.0.0.0/0` → IGW. Sem isso, a instância pode receber IP público e ainda **não** alcançar a internet.
4. **Security Groups ausentes:** o módulo EC2 exige IDs de SG, porém nenhum `aws_security_group` é definido no projeto — é necessário criá-los ou referenciar SGs existentes.
5. **Módulo ALB órfão:** `modules/ALB` está pronto (ALB, target group, listener HTTP:80, attachment na EC2), mas **não** é chamado em `main.tf`. ALB exige pelo menos duas subnets em AZs diferentes na maioria dos casos — a VPC atual só cria uma subnet.
6. **Dois blocos `terraform`:** `main.tf` (backend) e `provider.tf` (required_providers) — válido no Terraform; mantenha os dois alinhados.

Integração sugerida (referência — ajuste AMI e regras de SG conforme sua aplicação):

```hcl
module "ec2" {
  source = "./modules/EC2"

  ami_id             = "ami-xxxxxxxx" # AMI válida em us-east-1
  instance_type      = "t3.micro"
  subnet_id          = module.vpc.subnet_id
  security_group_ids = [aws_security_group.ec2.id]
  instance_name      = "terraform-ec2"
}
```

## Referências

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)
- [Backend S3](https://developer.hashicorp.com/terraform/language/backend/s3)