# Testes reproduzíveis

## Regras unitárias

`npm test` cobre intervalos, buffers, antecedência/horizonte, fronteira de cancelamento, mudança horária de Lisboa, datas reais, consentimento, rejeição de HTML, NIF, limite bcrypt, CSRF, payload e sinais fixos/percentuais.

## PostgreSQL isolado

Copie `docs/test-environment.example` para `.env.test` (ignorado) com `DATABASE_URL` e `DIRECT_URL` a apontar para uma base **lumiere_test**, um AUTH_SECRET só de teste e `DEPLOYMENT_ENV=test`. Não defina credenciais comerciais de mensagens ou pagamentos.

```bash
node --env-file=.env.test ./node_modules/prisma/build/index.js migrate deploy
npm run test:integration
```

O teste recusa outro nome de base antes de fazer TRUNCATE. Cria fixtures claramente identificadas e verifica: dois holds concorrentes para um slot; constraint de exclusão; titularidade; confirmação repetida; transferência com alteração de duração/preço; expiração; limite de sinais simultâneos; webhooks duplicados/tardios; pontos e resgates concorrentes; tokens descartáveis; ausência de envios simulados.

Os eventos Stripe são **fixtures de teste**, não chamadas a uma conta real. A assinatura HTTP e a aceitação comercial também devem ser exercitadas com Stripe CLI e a conta de teste do responsável.

## Navegador

```bash
npx playwright install --with-deps chromium
npm run build
npm run start
# Testes públicos, PWA e acessibilidade:
npm run test:e2e
# Inclui mutações locais e painel de administração:
E2E_ALLOW_MUTATIONS=true \
E2E_ADMIN_EMAIL='<conta local>' \
E2E_ADMIN_PASSWORD='<segredo local>' npm run test:e2e
```

Por omissão, o teste usa `http://127.0.0.1:3000`. `PLAYWRIGHT_BASE_URL` só deve apontar a um ambiente isolado autorizado. Os testes de mutação criam dados temporários e removem-nos; não devem correr numa base de clientes reais. As credenciais não ficam no ficheiro de teste.

Os testes usam estados explícitos e verificam o menu. Há também um ensaio de navegação imediata, sem esperar pelo menu, que confirma a ausência de erros de hidratação. Não use `networkidle` como critério geral com SSE e polling.

### Novos ensaios numa instância isolada

Execute primeiro os testes de integração e só depois prepare os cenários de navegador, pois estes conjuntos reinicializam a mesma base de teste.

```bash
node --env-file=.env.test --import ./scripts/test-boundary.mjs --import tsx scripts/prepare-browser-tests.ts
node --env-file=.env.test --import ./scripts/test-boundary.mjs ./node_modules/next/dist/bin/next start --hostname 0.0.0.0 --port 3100
```

O primeiro comando cria credenciais aleatórias de ensaio em `.cache/browser-fixtures.json`, nunca no repositório. Use os valores desse ficheiro para `E2E_ADMIN_EMAIL`/`E2E_ADMIN_PASSWORD`, e execute Playwright com `PLAYWRIGHT_BASE_URL=http://127.0.0.1:3100`, `E2E_ISOLATED=true`, `E2E_ALLOW_MUTATIONS=true` e as variáveis de `.env.test` carregadas. Não execute estes ensaios contra a base principal.

São cobertos acessos de duas profissionais, registos financeiros parciais, recusa de pagamentos manuais, conflito entre revisões de rascunho e revogação/mudança de conta. O preloader desativa prestadores e Redis para impedir chamadas externas e interferência com a cache principal. As respostas Stripe usadas nos testes de domínio são fixtures explícitas, não um modo de simulação exposto pela aplicação.

## Aceitação externa ainda necessária

- Stripe em teste: cartão, MB WAY e Multibanco habilitados, assinatura inválida, valor incorreto, atraso, repetição, cancelamento e reembolso.
- Resend/Twilio: domínio/remetente real, entrega, rejeição, limites, falhas e reconciliação de SMS incerto.
- iOS/Android reais: instalar, abrir em standalone, offline após reiniciar, atualizar PWA e validar preferências de acessibilidade.
- Profissional associada: segunda conta e segunda agenda, acesso isolado e desativação.
- Carga e restauro: concorrência superior à fixture, limites de pool, cron atrasado e recuperação de backup.
- Revisão humana dos dados comerciais, conteúdo, direitos de imagem e documentação jurídica.

## Horário e prontidão

A suite inclui sobreposição de intervalos, cruzamento com turnos, fecho com buffers, horas inexistentes na mudança sazonal, exceções que substituem a semana e limites reais do dia. Em PostgreSQL, verifica confirmação de impacto, token desatualizado, novas reservas concorrentes, revisões antigas, remoção de exceção e snapshot Serializable alterado durante espera.

São também testados pulso concorrente, códigos de erro sem dados sensíveis, credenciais versus evidência correspondente, rotação de configuração e assinatura válida/inválida do webhook. No navegador, a administração altera um horário, confirma a preservação das reservas e verifica contactos/rodapé e controlo de acesso.
