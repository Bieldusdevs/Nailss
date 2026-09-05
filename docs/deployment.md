# Publicação e ambientes

## Separação obrigatória

| Ambiente | Base de dados/cache | Stripe | Indexação |
|---|---|---|---|
| development | local, nunca partilhada com clientes | sem chaves ou teste | bloqueada |
| preview | infraestrutura isolada, dados sintéticos autorizados | chaves de teste | bloqueada |
| production | projeto/roles próprios, backups e TLS | conta comercial validada | autorizada após validação |

Configure `DEPLOYMENT_ENV` explicitamente. `NODE_ENV=production` apenas descreve a compilação otimizada; não autoriza o uso comercial. Use `SITE_URL` correto em cada ambiente. Não reutilize AUTH_SECRET, CRON_SECRET, Redis, buckets ou webhooks entre ambientes.

## PostgreSQL e Redis

1. Crie PostgreSQL gerido numa região UE adequada. Ative `btree_gist` antes da primeira migration se o fornecedor o exigir.
2. `DATABASE_URL` pode usar um pooler compatível; `DIRECT_URL` deve ser uma ligação direta para migrations. Configure TLS, limites de ligação e credenciais com privilégios mínimos.
3. Migre com `npm run db:migrate`. A seed é para instalação inicial deliberada, não para todos os deploys.
4. Redis usa protocolo Redis (`redis://`/`rediss://`), não uma URL REST. Proteja-o com autenticação, TLS e rede privada. A indisponibilidade da cache não desativa o rate limit: existe fallback persistente em PostgreSQL.
5. O PostgreSQL trust e o Redis sem autenticação da sandbox são **exclusivos do desenvolvimento**, não um modelo de produção.

## Vercel e Git

O repositório inclui `vercel.json`: App Router, migrations no build, região inicial `cdg1` e cron de minuto a minuto. Ligue o repositório a um projeto Vercel e associe os ambientes Git correspondentes. Não foi efetuado push nem publicação numa conta externa nesta entrega.

- Production: ramo aprovado, domínio e variáveis comerciais.
- Preview: ramo/PR com base, Redis e Stripe de teste independentes.
- Development: ficheiro `.env` local, ignorado pelo Git.

O plano Vercel deve suportar a frequência do cron e o orçamento de execução. Caso contrário, use um worker Node persistente com `npm run worker`, protegido por supervisão e sem exposição HTTP. Não dependa de uma função iniciada por um pedido de cliente para enviar lembretes.

O cron chama `/api/cron/reminders` com `Authorization: Bearer <CRON_SECRET>`. A autenticação e as leases mantêm a operação segura perante repetições. Monitorize atrasos; uma configuração de cron diária não satisfaz lembretes de 24h e 2h.

## Pagamentos e comunicação

- Stripe: configure `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET` e métodos separados por vírgulas. Eventos: `checkout.session.completed`, `checkout.session.async_payment_succeeded`, `checkout.session.expired`, `checkout.session.async_payment_failed`, `refund.created`, `refund.updated`, `refund.failed`.
- Cartão e MB WAY dependem da habilitação da conta. Multibanco é opcional e só é proposto para cuidados a mais de 72 horas; um pagamento após o bloqueio expirar é reembolsado, sem confirmar a agenda.
- Faça primeiro a aceitação com Stripe CLI/ambiente de teste, incluindo reentrega, expiração e reembolso. Não há um pagamento real validado sem as credenciais do comerciante.
- Resend: domínio verificado, SPF/DKIM/DMARC, `RESEND_API_KEY` e `MAIL_FROM`. A caixa de envio apresentada na app é administrativa; entregabilidade deve ser acompanhada no prestador.
- Twilio: SID, token e remetente autorizado para Portugal, saldo e regras de consentimento. Contactos locais de nove dígitos são normalizados para +351; internacionais usam E.164.
- Imagens: `BLOB_READ_WRITE_TOKEN` ativa armazenamento persistente Vercel Blob. O fallback de disco serve apenas desenvolvimento/self-hosting com volume persistente; não é usado num deploy Vercel sem Blob configurado.

## Segurança antes do lançamento

Produção exige HTTPS, AUTH_SECRET aleatório com pelo menos 32 caracteres, CRON_SECRET, base de dados, email configurado e `REQUIRE_VERIFIED_EMAIL=true`. Não exponha segredos com prefixo NEXT_PUBLIC_. Valide os cabeçalhos de ingress antes de ativar TRUST_PROXY. Em Vercel é usado o cabeçalho de origem fornecido pela plataforma.

A opção `legalVerified` é uma declaração do responsável, não uma certificação automática. Substitua os dados de exemplo e complete/reveja textos legais, identificação RAL, retenção, DPA, acessibilidade e direitos de imagem antes de a ativar. O schema NailSalon só é publicado depois desta declaração.

O pagamento restante no atelier não emite, por si só, fatura fiscal. Integre o processo de faturação certificado aplicável à operação portuguesa.

## Observabilidade, backup e rollback

- `/api/health` verifica a base de dados sem expor configuração.
- Logs estruturados e AuditEvent registam ações sem palavras-passe ou corpos de mensagens.
- `OTEL_EXPORTER_OTLP_ENDPOINT` e `OTEL_EXPORTER_OTLP_HEADERS` ativam o exportador OpenTelemetry do servidor. Configure no coletor a remoção de query strings, tokens de links e atributos sensíveis.
- Alertas: health não OK, 5xx, outbox BLOCKED/FAILED/SENDING fora de lease, REFUND_PENDING antigo e ausência de cron.
- Ative PITR/backups e teste um restauro para um ambiente isolado. Faça rollback do código apenas com migrations compatíveis; não reverta tabelas com pagamentos por tentativa/erro.
- Uma publicação altera a versão da cache. A PWA anuncia a atualização e pede que se terminem os formulários antes de recarregar.

## Migração de horário e prontidão

A migration `202609050002_opening_readiness` cria o horário inicial fornecido e tabelas de exceções, pulso e evidências. Execute migrations antes de publicar o código e reinicie o worker para começar a produzir o pulso. Não execute a seed para repor turnos: a seed é create-only e preserva alterações existentes.

Depois do deploy, consulte Preparar a abertura. Os sinais a zero dispensam Stripe, mas um envio configurado não é uma prova de entrega; uma assinatura recebida não prova métodos de pagamento. As pendências jurídicas, de imagem e de restauro continuam a depender do responsável.
