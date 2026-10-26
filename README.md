# Cupons ACIAI - Validador de Cupons Fiscais e Sorteios

Aplicativo oficial em **Flutter** para participação nas campanhas promocionais e sorteios sazonais da **ACIAI** (Natal, Mês das Mães, Dia dos Pais, Black Friday, etc.).

---

## 📱 Funcionalidades Principais

1. **Cadastro Completo do Consumidor:**
   - Nome Completo, CPF (com validação oficial de 11 dígitos e cálculo de DVs), Data de Nascimento, E-mail e Senha.
   - Vinculação obrigatória do CPF a cada bilhete/número da sorte gerado.

2. **Validador Fiscal Inteligente (NFC-e / SAT):**
   - Leitor de QR Code via câmera do dispositivo ou digitação manual da chave de 44 dígitos.
   - **Extração automática** da Chave de Acesso (44 dígitos), CNPJ da loja emissora e valor da compra.
   - **Regra de Valor:** Apenas compras a partir de **R\$ 50,00**.
   - **Regra de Associado ACIAI:** Apenas notas emitidas por CNPJs de lojas associadas participantes da campanha.
   - **Antifraude:** Verificação de unicidade para impedir reuso do mesmo cupom fiscal.
   - **Geração de Números da Sorte:** Geração automática de 1 número da sorte a cada R\$ 50,00 gastos na compra.

3. **Design e Identidade:**
   - **Tema Claro (Light Theme)** minimalista.
   - Toques sofisticados de verde esmeralda e floresta (`#0F766E`, `#10B981`, `#F0FDF4`).
   - Cards clean, tipografia legível e alta usabilidade para o consumidor.

4. **Painel e Extrato:**
   - Acompanhamento dos números da sorte conquistados.
   - Consulta de lojas associadas participantes por categoria, nome ou CNPJ.
   - Simulação e testes instantâneos de regras no próprio app.

---

## 📂 Estrutura do Projeto

```
lib/
├── core/
│   ├── theme/
│   │   └── app_theme.dart          # Tema claro, cores e estilo minimalista
│   └── utils/
│       ├── cpf_validator.dart      # Validação e máscara de CPF
│       └── coupon_parser.dart      # Parser de QR Code NFC-e/SAT e chave de 44 dígitos
├── models/
│   ├── campaign_model.dart         # Campanhas promocionais sazonais
│   ├── coupon_model.dart           # Cupons fiscais validados e números da sorte
│   ├── merchant_model.dart         # Lojas associadas da ACIAI
│   └── user_model.dart             # Dados do participante
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart       # Autenticação
│   │   └── register_screen.dart    # Cadastro com CPF e Data de Nascimento
│   ├── coupons/
│   │   └── my_coupons_screen.dart  # Extrato de cupons e números da sorte
│   ├── home/
│   │   └── home_screen.dart        # Dashboard principal
│   ├── merchants/
│   │   └── merchants_list_screen.dart # Consulta de lojas participantes
│   └── scanner/
│       ├── scanner_screen.dart     # Visor de leitura de QR Code e simulação
│       └── validation_result_dialog.dart # Modal de aprovação / recusa
├── services/
│   ├── auth_service.dart           # Sessão e login do usuário
│   ├── campaign_service.dart       # Gestão de campanhas e lojas da ACIAI
│   └── validation_service.dart     # Motor de validação das regras fiscais
├── widgets/
│   ├── campaign_card.dart
│   ├── lucky_number_badge.dart
│   └── stat_card.dart
└── main.dart                       # Entrada do aplicativo
```

---

## 🚀 Como Executar

### Pré-requisitos
- Flutter SDK instalado ([guia de instalação](https://docs.flutter.dev/get-started/install))
- VS Code ou Android Studio com as extensões Flutter e Dart.

### Passos
```bash
# 1. Obter as dependências
flutter pub get

# 2. Executar no emulador, dispositivo físico ou Chrome
flutter run
```
